import CoreData
import SwiftUI

struct TimelineScreen: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Binding private var selectedTab: RootTab
    @State private var selectedScope: TimelineScope = .today
    @State private var days: [TimelineDay] = []
    @State private var snapshots: [TimelineReviewSnapshotKind: TimelineReviewSnapshotPayload] = [:]
    @State private var isRefreshingSnapshots = false
    @State private var selectedDay: TimelineDay? = nil
    @State private var selectedCapture: CaptureItem? = nil
    @State private var selectedAtom: AtomItem? = nil

    private let aiService: AIService

    init(
        aiService: AIService = AIServiceFactory.make(),
        selectedTab: Binding<RootTab> = .constant(.timeline)
    ) {
        self.aiService = aiService
        _selectedTab = selectedTab
    }

    private var atomStore: AtomTagStore { AtomTagStore(context: context) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                headerView

                Picker("范围", selection: $selectedScope) {
                    ForEach(TimelineScope.timelineTabs) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if shouldShowRangeSummary {
                            rangeSummaryView

                        }

                        if days.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(days) { day in
                                TimelineDayCard(
                                    day: day,
                                    onOpenDay: { openDay(day) },
                                    onHighlightTap: { index in
                                        let ids = day.highlightCaptureIDs
                                        guard ids.indices.contains(index) else { return }
                                        let captureID = ids[index]
                                        let text = day.secondaryLines.indices.contains(index) ? day.secondaryLines[index] : ""
                                        openHighlight(captureID: captureID, highlightText: text)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: TimelineDay.self) { day in
                DayDetailScreen(day: day, aiService: aiService)
            }
            .navigationDestination(item: $selectedDay) { day in
                DayDetailScreen(day: day, aiService: aiService)
            }
            .sheet(item: $selectedCapture) { item in
                CaptureDetailSheet(item: item, context: context)
            }
            .sheet(item: $selectedAtom) { atom in
                AtomDetailSheet(atom: atom, context: context, onSaved: loadDays)
            }
            .onAppear {
                loadDays()
                refreshSnapshotsIfNeeded(prioritizedKind: currentSnapshotKind)
            }
            .onChange(of: selectedScope) { _, _ in
                loadDays()
                refreshSnapshotsIfNeeded(prioritizedKind: currentSnapshotKind)
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                refreshSnapshotsIfNeeded(prioritizedKind: currentSnapshotKind)
            }
        }
    }

    private var headerView: some View {
        Text("今天 · \(formattedTodayDate(Date()))")
            .font(.title2.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
    }

    private var rangeSummaryView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(summaryTitle)
                .font(.headline)
                .foregroundStyle(.primary)

            if isRefreshingSnapshots && currentSnapshot == nil {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("正在整理最近一次可回看的故事线…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                summaryTextBlock(currentSummaryDisplay)
            }

            if let snapshot = currentSnapshot, snapshot.activeDayCount > 0 || snapshot.totalRecordCount > 0 {
                HStack(spacing: 8) {
                    snapshotPill("\(snapshot.activeDayCount) 天")
                    snapshotPill("\(snapshot.totalRecordCount) 条材料")
                }

                if !snapshot.overviewSignals.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(snapshot.overviewSignals, id: \.self) { signal in
                                signalPill(signal)
                            }
                        }
                    }
                }
            } else if !days.isEmpty {
                Text(fallbackStatsText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(emptyStateBody)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                selectedTab = .record
            } label: {
                Text("记一句")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            Text("不用补完整，零散片段也会慢慢接成你的时间脉络。")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var currentSummaryDisplay: TimelineSnapshotSummaryDisplay {
        if let snapshot = currentSnapshot {
            return makeSummaryDisplay(from: snapshot.summaryText)
        }
        return TimelineSnapshotSummaryDisplay(lead: fallbackSummaryText, connection: nil)
    }

    private var emptyStateTitle: String {
        switch selectedScope {
        case .today:
            return "昨天还没有留下片段"
        case .week:
            return "最近 7 天还没有留下片段"
        case .month:
            return "最近 30 天还没有留下片段"
        case .custom:
            return "最近 30 天还没有留下片段"
        }
    }

    private var emptyStateBody: String {
        switch selectedScope {
        case .today:
            return "今天先把片段放进来，明天这里会留下更稳定的回看。"
        case .week:
            return "不用补满 7 天，从现在记一句就够了。"
        case .month:
            return "不用补满 30 天，先把当下留下来。"
        case .custom:
            return "这不是待办清单。记下一句话，这里就会开始长出时间感。"
        }
    }

    private func loadDays() {
        let calendar = Calendar.current
        guard let interval = dateInterval(for: selectedScope) else {
            days = []
            return
        }

        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            interval.start as CVarArg,
            interval.end as CVarArg
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let captures = ((try? context.fetch(request)) ?? [])
            .filter(\.isEligibleForReviewTimeline)
        let grouped = Dictionary(grouping: captures) { capture in
            calendar.startOfDay(for: capture.createdAt)
        }

        days = grouped.map { date, items in
            buildDay(date: date, items: items)
        }
        .sorted { $0.date > $1.date }
    }

    private var shouldShowRangeSummary: Bool {
        currentSnapshot != nil || isRefreshingSnapshots || !days.isEmpty
    }

    private var currentSnapshotKind: TimelineReviewSnapshotKind {
        switch selectedScope {
        case .today:
            return .yesterday
        case .week:
            return .last7Days
        case .month, .custom:
            return .last30Days
        }
    }

    private var currentSnapshot: TimelineReviewSnapshotPayload? {
        snapshots[currentSnapshotKind]
    }

    private var summaryTitle: String {
        currentSnapshotKind.title
    }

    private var fallbackSummaryText: String {
        let dayCount = days.count
        let recordCount = days.reduce(0) { $0 + $1.recordCount }
        if dayCount == 0 || recordCount == 0 {
            return "这段时间还没有足够的片段形成一条稳定故事线。"
        }
        switch currentSnapshotKind {
        case .yesterday:
            return "昨天的故事线还在等待整理，先看看昨天留下了什么。"
        case .last7Days:
            return "过去 7 天的故事线还在等待整理，先按日期看看最近留下了什么。"
        case .last30Days:
            return "过去 30 天的故事线还在等待整理，先把这些日期放在这里。"
        }
    }

    private var fallbackStatsText: String {
        let dayCount = days.count
        let recordCount = days.reduce(0) { $0 + $1.recordCount }
        guard dayCount > 0, recordCount > 0 else { return "" }
        return "当前这一栏里有 \(dayCount) 天、\(recordCount) 条片段。"
    }

    private func snapshotPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
    }

    private func signalPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func summaryTextBlock(_ display: TimelineSnapshotSummaryDisplay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(display.lead)
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(.primary)
                .lineLimit(4)

            if let connection = display.connection {
                VStack(alignment: .leading, spacing: 4) {
                    Text("可能的联系")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)

                    Text(connection)
                        .font(.footnote)
                        .lineSpacing(3)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
    }

    private func makeSummaryDisplay(from rawText: String) -> TimelineSnapshotSummaryDisplay {
        let sections = labeledSummarySections(from: rawText)
        let leadSource = sections["事实"]
            ?? sections["总结"]
            ?? sections["主要主题"]
            ?? firstMeaningfulParagraph(from: rawText)
            ?? fallbackSummaryText
        let connectionSource = sections["联系"] ?? sections["可能的联系"]
        let lead = compactSummaryText(leadSource, maxLength: 118)
        let connection = connectionSource
            .map { compactSummaryText($0, maxLength: 96) }
            .flatMap { $0.isEmpty ? nil : $0 }

        return TimelineSnapshotSummaryDisplay(lead: lead, connection: connection)
    }

    private func labeledSummarySections(from rawText: String) -> [String: String] {
        let labels = ["事实", "联系", "可能的联系", "可继续问", "总结", "主要主题"]
        var normalized = rawText
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "**", with: "")

        for label in labels {
            normalized = normalized
                .replacingOccurrences(of: "\(label)：", with: "\n\(label)：")
                .replacingOccurrences(of: "\(label):", with: "\n\(label):")
        }

        var sections: [String: String] = [:]
        var currentLabel: String?
        var buffer = ""

        func flush() {
            guard let currentLabel else { return }
            let text = compactSummaryText(buffer, maxLength: 220)
            if !text.isEmpty {
                sections[currentLabel] = text
            }
        }

        for rawLine in normalized.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if let match = summaryLabelMatch(line, labels: labels) {
                flush()
                currentLabel = match.label
                buffer = match.remainder
            } else if currentLabel != nil {
                buffer += buffer.isEmpty ? line : " \(line)"
            }
        }

        flush()
        return sections
    }

    private func summaryLabelMatch(_ line: String, labels: [String]) -> (label: String, remainder: String)? {
        for label in labels {
            for separator in ["：", ":"] {
                let prefix = "\(label)\(separator)"
                guard line.hasPrefix(prefix) else { continue }
                let remainder = String(line.dropFirst(prefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return (label, remainder)
            }
        }
        return nil
    }

    private func firstMeaningfulParagraph(from rawText: String) -> String? {
        rawText
            .replacingOccurrences(of: "**", with: "")
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { paragraph in
                !paragraph.isEmpty
                    && !paragraph.hasPrefix("可继续问：")
                    && !paragraph.hasPrefix("可继续问:")
            }
    }

    private func compactSummaryText(_ text: String, maxLength: Int) -> String {
        let cleaned = text
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count > maxLength else { return cleaned }

        let endIndex = cleaned.index(cleaned.startIndex, offsetBy: maxLength)
        return cleaned[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private func refreshSnapshotsIfNeeded(prioritizedKind: TimelineReviewSnapshotKind) {
        let service = TimelineReviewSnapshotService(context: context)
        for kind in TimelineReviewSnapshotKind.allCases {
            if let snapshot = service.loadSnapshot(kind: kind), service.isSnapshotCurrent(snapshot) {
                snapshots[kind] = snapshot
            } else {
                snapshots[kind] = nil
            }
        }

        guard !isRefreshingSnapshots else { return }
        isRefreshingSnapshots = true

        Task {
            let orderedKinds = [prioritizedKind] + TimelineReviewSnapshotKind.allCases.filter { $0 != prioritizedKind }
            for kind in orderedKinds {
                if let snapshot = await service.refreshIfNeeded(kind: kind, aiService: aiService) {
                    await MainActor.run {
                        snapshots[kind] = snapshot
                    }
                }
            }
            await MainActor.run {
                isRefreshingSnapshots = false
            }
        }
    }

    private func buildDay(date: Date, items: [CaptureEntity]) -> TimelineDay {
        let sorted = items.sorted { $0.createdAt > $1.createdAt }
        let texts = sorted.map(displayText(for:))
        let dedupedTexts = uniqueTexts(from: texts)
        let dayParts = Array(NSOrderedSet(array: sorted.compactMap {
            DayPart(rawValue: $0.dayPart ?? "")
        })) as? [DayPart] ?? []
        let secondaryLines = Array(dedupedTexts.prefix(3))
        let primaryLine = primaryLine(for: dedupedTexts, count: items.count)
        let secondaryCaptureIDs = Array(sorted.prefix(secondaryLines.count).map(\.id))

        return TimelineDay(
            id: UUID(),
            date: date,
            recordCount: items.count,
            dayParts: dayParts,
            primaryLine: primaryLine,
            secondaryLines: secondaryLines,
            highlightCaptureIDs: secondaryCaptureIDs,
            hasGeneratedNarrative: false
        )
    }

    private func displayText(for capture: CaptureEntity) -> String {
        let text = (capture.cleanText ?? capture.rawText).trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedSnippet(from: text)
    }

    private func uniqueTexts(from texts: [String]) -> [String] {
        var seen: Set<String> = []
        var ordered: [String] = []

        for text in texts where !text.isEmpty {
            let key = text.lowercased()
            if seen.insert(key).inserted {
                ordered.append(text)
            }
        }

        return ordered
    }

    private func normalizedSnippet(from text: String, maxLength: Int = 56) -> String {
        let normalized = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else {
            return "留下一小段片段。"
        }

        guard normalized.count > maxLength else {
            return normalized
        }

        let cutIndex = normalized.index(normalized.startIndex, offsetBy: maxLength)
        return normalized[..<cutIndex].trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private func primaryLine(for texts: [String], count: Int) -> String {
        guard let first = texts.first else {
            return "这一天还没有能展示的片段。"
        }

        if count == 1 {
            return first
        }

        if let second = texts.dropFirst().first {
            return "这一天留下了 \(count) 条片段，先是\(first)，后来也提到\(second)"
        }

        return "这一天留下了 \(count) 条片段，主要围绕\(first)"
    }

    private func dateInterval(for scope: TimelineScope) -> DateInterval? {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        switch scope {
        case .today:
            let start = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
            return DateInterval(start: start, end: todayStart)
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: todayStart) ?? todayStart
            return DateInterval(start: start, end: todayStart)
        case .month:
            let start = calendar.date(byAdding: .day, value: -30, to: todayStart) ?? todayStart
            return DateInterval(start: start, end: todayStart)
        case .custom:
            let start = calendar.date(byAdding: .day, value: -30, to: todayStart) ?? todayStart
            return DateInterval(start: start, end: todayStart)
        }
    }

    private func formattedTodayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func openHighlight(captureID: UUID, highlightText: String) {
        let atoms = atomStore.fetchAtoms(captureID: captureID)
        if let matched = atoms.first(where: { atom in
            atom.content.contains(highlightText) || highlightText.contains(atom.content)
        }) {
            selectedAtom = matched
            return
        }

        loadCapture(id: captureID)
    }

    private func openDay(_ day: TimelineDay) {
        selectedDay = day
    }

    private func loadCapture(id: UUID) {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let entity = try? context.fetch(request).first else { return }
        let item = CaptureItem(
            id: entity.id,
            createdAt: entity.createdAt,
            rawText: entity.rawText,
            cleanText: entity.cleanText,
            ackTitle: entity.ackTitle,
            ackDetail: entity.ackDetail,
            dayPart: DayPart(rawValue: entity.dayPart ?? "") ?? .morning,
            mode: entity.resolvedInputMode,
            assistRecord: nil,
            atomsCount: Int(entity.atomsCount),
            processingState: entity.resolvedReviewProcessingState,
            inputType: CaptureInputType(rawValue: entity.inputType ?? "") ?? .text,
            audioPath: entity.audioPath,
            transcriptText: entity.transcriptText,
            transcriptionStatus: TranscriptionStatus(rawValue: entity.transcriptionStatus ?? ""),
            transcriptionErrorReason: entity.transcriptionError,
            isTranscriptionActive: false
        )
        selectedCapture = item
    }
}

private struct TimelineSnapshotSummaryDisplay {
    let lead: String
    let connection: String?
}

private struct TimelineDayCard: View {
    let day: TimelineDay
    let onOpenDay: () -> Void
    let onHighlightTap: (Int) -> Void

    var body: some View {
        Button(action: onOpenDay) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate(day.date))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(metaLine)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }

                Text(day.primaryLine)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                if !day.secondaryLines.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(day.secondaryLines.enumerated()), id: \.offset) { index, highlight in
                            Button {
                                onHighlightTap(index)
                            } label: {
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(Color(.systemGray3))
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 7)
                                    Text(highlight)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text("回看这一天")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var metaLine: String {
        let recordText = "\(day.recordCount) 条片段"
        guard !day.dayParts.isEmpty else {
            return recordText
        }
        let partText = day.dayParts.map(\.title).joined(separator: " / ")
        return "\(recordText) · \(partText)"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }
}
