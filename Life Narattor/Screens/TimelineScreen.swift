import CoreData
import SwiftUI

struct TimelineScreen: View {
    @Environment(\.managedObjectContext) private var context
    @Binding private var selectedTab: RootTab
    @State private var selectedScope: TimelineScope = .today
    @State private var days: [TimelineDay] = []
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
            VStack(alignment: .leading, spacing: 16) {
                Picker("范围", selection: $selectedScope) {
                    ForEach(TimelineScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if days.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(days) { day in
                                TimelineDayCard(
                                    day: day,
                                    onOpenDay: { openDay(day) },
                                    onHighlightTap: { index in
                                        let ids = day.highlightCaptureIDs
                                        guard ids.indices.contains(index) else { return }
                                        let captureID = ids[index]
                                        let text = day.highlights.indices.contains(index) ? day.highlights[index] : ""
                                        openHighlight(captureID: captureID, highlightText: text)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
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
            .onAppear(perform: loadDays)
            .onChange(of: selectedScope) { _, _ in
                loadDays()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("时间线会按日期把记录整理出来。先去记录页写下第一条，这里就会开始出现内容。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                selectedTab = .record
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline.weight(.semibold))
                    Text("去记录页开始记录")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            Text("写下记录后再回到这里，就可以按天回看。")
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

    private var emptyStateTitle: String {
        switch selectedScope {
        case .today:
            return "今天还没有记录"
        case .week:
            return "本周还没有记录"
        case .month:
            return "本月还没有记录"
        case .custom:
            return "这段时间还没有记录"
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

        let captures = (try? context.fetch(request)) ?? []
        let grouped = Dictionary(grouping: captures) { capture in
            calendar.startOfDay(for: capture.createdAt)
        }

        days = grouped.map { date, items in
            let sorted = items.sorted { $0.createdAt > $1.createdAt }
            let pairs = sorted.compactMap { item -> (String, UUID)? in
                let text = item.cleanText ?? item.rawText
                return (text, item.id)
            }
            let highlights = pairs.map { $0.0 }.prefix(6)
            let highlightIDs = pairs.map { $0.1 }.prefix(6)
            return TimelineDay(
                id: UUID(),
                date: date,
                highlights: Array(highlights),
                highlightCaptureIDs: Array(highlightIDs),
                hasNarrative: items.count >= 3
            )
        }
        .sorted { $0.date > $1.date }
    }

    private func dateInterval(for scope: TimelineScope) -> DateInterval? {
        let calendar = Calendar.current
        let now = Date()
        switch scope {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return DateInterval(start: start, end: end)
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: now)
        case .month:
            return calendar.dateInterval(of: .month, for: now)
        case .custom:
            let end = now
            let start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
            return DateInterval(start: start, end: end)
        }
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
            mode: CaptureInputMode(rawValue: entity.mode ?? "") ?? .log,
            assistRecord: nil,
            atomsCount: Int(entity.atomsCount),
            processingState: CaptureProcessingState(rawValue: entity.processingState ?? "") ?? .cleanReady,
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

private struct TimelineDayCard: View {
    let day: TimelineDay
    let onOpenDay: () -> Void
    let onHighlightTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpenDay) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(day.date))
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(day.hasNarrative ? "查看当天整理" : "生成当天叙事")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.blue)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }

                    Text(day.hasNarrative ? "这一天已经有足够材料，可以直接进入查看整理结果。" : "这一天已有记录，进入后可以继续整理成更完整的当天叙事。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(day.highlights.enumerated()), id: \.offset) { index, highlight in
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
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }
}
