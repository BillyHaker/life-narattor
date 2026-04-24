import CoreData
import SwiftUI

struct DayDetailScreen: View {
    let day: TimelineDay

    private let aiService: AIService

    @State private var selectedCommentStyle: CommentStyle = .gentle
    @State private var isCommentEnabled: Bool = true
    @State private var capturesByPart: [DayPart: [CaptureRow]] = [:]
    @State private var selectedCapture: CaptureItem? = nil
    @State private var isSourcesExpanded: Bool = false
    @State private var narrativeText: String = "这一天还没有可整理的记录。"
    @State private var narrativeMaterial: NarrativeMaterial? = nil
    @State private var aiAnalysisText: String = ""
    @State private var isLoadingAIAnalysis = false
    @State private var aiAnalysisErrorMessage: String? = nil
    @Environment(\.managedObjectContext) private var context

    init(day: TimelineDay, aiService: AIService = AIServiceFactory.make()) {
        self.day = day
        self.aiService = aiService
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                narrativeSection
                commentSection
                recordsSection
                sourcesSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle(formattedHeaderDate(day.date))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .sheet(item: $selectedCapture) { item in
            CaptureDetailSheet(item: item, context: context)
        }
        .onAppear {
            refreshDayNarrative(forceAIRefresh: false)
        }
        .onChange(of: selectedCommentStyle) { _, _ in
            guard isCommentEnabled else { return }
            requestAIAnalysisIfNeeded(force: true)
        }
        .onChange(of: isCommentEnabled) { _, isEnabled in
            guard isEnabled else { return }
            requestAIAnalysisIfNeeded(force: aiAnalysisText.isEmpty)
        }
    }

    private var headerSection: some View {
        Text(formattedHeaderDate(day.date))
            .font(.title2.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var narrativeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日叙事")
                .font(.headline)

            Text(narrativeText)
                .font(.body)
                .foregroundStyle(sourceMappings.isEmpty ? .secondary : .primary)

            HStack(spacing: 12) {
                Button("编辑叙事") {}
                    .buttonStyle(.bordered)
                    .disabled(true)
                Button("重新整理") {
                    refreshDayNarrative(forceAIRefresh: true)
                }
                .buttonStyle(.bordered)
                .disabled(capturesByPart.isEmpty)
            }
        }
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI 轻回应")
                    .font(.headline)
                Spacer()
                Toggle("关闭回应", isOn: $isCommentEnabled)
                    .labelsHidden()
            }

            if isCommentEnabled {
                Picker("风格", selection: $selectedCommentStyle) {
                    ForEach(CommentStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    if isLoadingAIAnalysis {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("正在整理这一天的线索…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if let aiAnalysisErrorMessage, !aiAnalysisErrorMessage.isEmpty {
                        Text(aiAnalysisErrorMessage)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(aiAnalysisText.isEmpty ? "记录还比较少，我先不硬分析。再多记几条后，这里会更有参考。" : aiAnalysisText)
                            .foregroundStyle(aiAnalysisText.isEmpty ? .secondary : .primary)
                    }
                }
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日记录")
                .font(.headline)
            if capturesByPart.isEmpty {
                Text("今天还没有记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(DayPart.allCases) { part in
                    if let rows = capturesByPart[part], !rows.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(part.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ForEach(rows) { row in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(Color(.systemGray3))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    Text(row.text)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DisclosureGroup("引用来源", isExpanded: $isSourcesExpanded) {
                if sourceMappings.isEmpty {
                    Text("暂无引用来源")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sourceMappings) { row in
                            Button {
                                loadCapture(id: row.captureID)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(row.sentence)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text("来自 \(formattedTime(row.createdAt))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .font(.headline)
        }
    }

    private func formattedHeaderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd · EEEE"
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private var allCaptures: [CaptureRow] {
        capturesByPart.values
            .flatMap { $0 }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var fallbackNarrativeParagraph: String {
        guard !sourceMappings.isEmpty else {
            return "这一天还没有可整理的记录。"
        }
        return sourceMappings.map(\.sentence).joined()
    }

    private var sourceMappings: [NarrativeSourceRow] {
        let units = narrativeUnits
        guard !units.isEmpty else {
            return []
        }

        return units.enumerated().map { index, unit in
            let sentence = normalizeNarrativeSentence(
                buildNarrativeSentence(
                    index: index,
                    total: units.count,
                    unit: unit,
                    previousDayPart: index > 0 ? units[index - 1].dayPartText : nil
                )
            )
            return NarrativeSourceRow(
                id: "\(unit.capture.id.uuidString)-\(index)",
                sentence: sentence,
                captureID: unit.capture.id,
                createdAt: unit.capture.createdAt
            )
        }
    }

    private var narrativeUnits: [NarrativeUnit] {
        let captures = Array(allCaptures.suffix(8))
        guard !captures.isEmpty else { return [] }

        var order: [String] = []
        var dedupMap: [String: NarrativeUnit] = [:]

        for capture in captures {
            let snippet = narrativeSnippet(from: capture.text)
            let part = dayPartText(for: capture.createdAt)
            let key = narrativeDedupKey(from: capture.text, fallback: snippet)

            if var existing = dedupMap[key] {
                existing.duplicateCount += 1
                dedupMap[key] = existing
            } else {
                order.append(key)
                dedupMap[key] = NarrativeUnit(
                    capture: capture,
                    snippet: snippet,
                    dayPartText: part,
                    duplicateCount: 1
                )
            }
        }

        return order.compactMap { dedupMap[$0] }
    }

    private func buildNarrativeSentence(
        index: Int,
        total: Int,
        unit: NarrativeUnit,
        previousDayPart: String?
    ) -> String {
        if total == 1 {
            if unit.duplicateCount > 1 {
                return "今天\(unit.dayPartText)围绕\(unit.snippet)反复记录了\(unit.duplicateCount)次。"
            }
            return "今天\(unit.dayPartText)记录了\(unit.snippet)。"
        }

        if unit.duplicateCount > 1 {
            if index == 0 {
                return "今天\(unit.dayPartText)先集中记录\(unit.snippet)（共\(unit.duplicateCount)次）。"
            }
            if previousDayPart == unit.dayPartText {
                return "随后又多次提到\(unit.snippet)（共\(unit.duplicateCount)次）。"
            }
            return "在\(unit.dayPartText)也多次提到\(unit.snippet)（共\(unit.duplicateCount)次）。"
        }

        if index == 0 {
            return "今天\(unit.dayPartText)先记下\(unit.snippet)。"
        }

        if index == total - 1 {
            if previousDayPart == unit.dayPartText {
                return "最后又补充了\(unit.snippet)。"
            }
            return "后来在\(unit.dayPartText)又补充了\(unit.snippet)。"
        }

        if previousDayPart == unit.dayPartText {
            return "随后也提到\(unit.snippet)。"
        }
        return "在\(unit.dayPartText)也提到\(unit.snippet)。"
    }

    private func normalizeNarrativeSentence(_ sentence: String) -> String {
        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        let punctuationTrimmed = trimmed.replacingOccurrences(
            of: "[。.!！？?]+$",
            with: "",
            options: .regularExpression
        )
        return punctuationTrimmed + "。"
    }

    private func narrativeSnippet(from text: String, maxLength: Int = 28) -> String {
        let normalized = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else {
            return "「一段记录」"
        }

        let segment = preferredNarrativeSegment(from: normalized) ?? normalized
        let cleaned = trimNarrativePunctuation(from: segment)
        let safeSnippet = isMeaningfulSnippet(cleaned) ? cleaned : "一段记录"
        let clipped = truncateSnippetAtWordBoundaryIfNeeded(safeSnippet, maxLength: maxLength)
        return "「\(clipped)」"
    }

    private func preferredNarrativeSegment(from text: String) -> String? {
        let separators = CharacterSet(charactersIn: "。！？!?；;.\n")
        let segments = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !segments.isEmpty else {
            return nil
        }

        if let firstReadable = segments.first(where: { isMeaningfulSnippet($0) && $0.count >= 6 }) {
            return firstReadable
        }
        return segments.max(by: { $0.count < $1.count })
    }

    private func trimNarrativePunctuation(from text: String) -> String {
        var output = text.trimmingCharacters(in: .whitespacesAndNewlines)
        while let first = output.first, isNarrativeTrimCharacter(first) {
            output.removeFirst()
        }
        while let last = output.last, isNarrativeTrimCharacter(last) {
            output.removeLast()
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func truncateSnippetAtWordBoundaryIfNeeded(_ text: String, maxLength: Int) -> String {
        guard text.count > maxLength else {
            return text
        }

        let rawCut = text.index(text.startIndex, offsetBy: maxLength)
        let lowerOffset = max(8, Int(Double(maxLength) * 0.6))
        let lowerBound = text.index(text.startIndex, offsetBy: min(lowerOffset, maxLength))

        var finalCut = rawCut
        if isLikelyInsideLatinWord(text, at: rawCut),
           let boundary = previousWordBoundary(in: text, before: rawCut, lowerBound: lowerBound) {
            finalCut = boundary
        }

        var truncated = String(text[..<finalCut]).trimmingCharacters(in: .whitespacesAndNewlines)
        truncated = trimNarrativePunctuation(from: truncated)

        if truncated.isEmpty {
            truncated = String(text[..<rawCut]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return truncated + "…"
    }

    private func previousWordBoundary(
        in text: String,
        before index: String.Index,
        lowerBound: String.Index
    ) -> String.Index? {
        var cursor = index
        while cursor > lowerBound {
            let prevIndex = text.index(before: cursor)
            let prevChar = text[prevIndex]
            if isWordBoundaryCharacter(prevChar) {
                return prevIndex
            }
            cursor = prevIndex
        }
        return nil
    }

    private func isLikelyInsideLatinWord(_ text: String, at index: String.Index) -> Bool {
        guard index > text.startIndex, index < text.endIndex else {
            return false
        }
        let prevChar = text[text.index(before: index)]
        let currentChar = text[index]
        return isLatinWordCharacter(prevChar) && isLatinWordCharacter(currentChar)
    }

    private func isNarrativeTrimCharacter(_ char: Character) -> Bool {
        let trimSet = CharacterSet.whitespacesAndNewlines.union(
            CharacterSet(charactersIn: "，。！？；,.!?;:\"'“”‘’「」、()（）[]【】{}<>《》")
        )
        return char.unicodeScalars.allSatisfy { trimSet.contains($0) }
    }

    private func isWordBoundaryCharacter(_ char: Character) -> Bool {
        let boundarySet = CharacterSet.whitespacesAndNewlines.union(
            CharacterSet(charactersIn: "，。！？；,.!?;:\"'“”‘’「」、()（）[]【】{}<>《》/-_")
        )
        return char.unicodeScalars.allSatisfy { boundarySet.contains($0) }
    }

    private func isLatinWordCharacter(_ char: Character) -> Bool {
        guard let scalar = char.unicodeScalars.first, char.unicodeScalars.count == 1 else {
            return false
        }
        let value = scalar.value
        let isLower = (97...122).contains(value)
        let isUpper = (65...90).contains(value)
        let isNumber = (48...57).contains(value)
        return isLower || isUpper || isNumber
    }

    private func isMeaningfulSnippet(_ text: String) -> Bool {
        let meaningfulCount = text.unicodeScalars.filter { scalar in
            if CharacterSet.alphanumerics.contains(scalar) {
                return true
            }
            return (0x4E00...0x9FFF).contains(scalar.value)
        }.count
        return meaningfulCount >= 2
    }

    private func dayPartText(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return "上午"
        case 12..<18:
            return "下午"
        default:
            return "晚上"
        }
    }

    private func narrativeDedupKey(from text: String, fallback: String) -> String {
        let normalized = text
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(
                of: "[，。！？；,.!?;:\"'“”‘’、\\-_—]+",
                with: "",
                options: .regularExpression
            )

        if normalized.isEmpty {
            return fallback
        }
        return String(normalized.prefix(40))
    }

    private func refreshDayNarrative(forceAIRefresh: Bool) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day.date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? day.date

        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            start as CVarArg,
            end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let captures = (try? context.fetch(request)) ?? []
        var grouped: [DayPart: [CaptureRow]] = [:]

        for capture in captures {
            let part = DayPart(rawValue: capture.dayPart ?? "") ?? .morning
            let text = capture.cleanText ?? capture.rawText
            let processingState = CaptureProcessingState(rawValue: capture.processingState ?? "") ?? .cleanReady
            grouped[part, default: []].append(
                CaptureRow(
                    id: capture.id,
                    text: text,
                    createdAt: capture.createdAt,
                    processingState: processingState
                )
            )
        }

        capturesByPart = grouped

        let range = RetrievalTimeRange(start: start, end: end, label: formattedHeaderDate(day.date))
        let retrievalService = ReviewRetrievalService(context: context)
        let brief = retrievalService.makeOpenReviewBrief(periodLabel: "这一天", range: range)
        let material = retrievalService.makeNarrativeMaterial(from: brief)

        narrativeMaterial = material.representativeUnits.isEmpty ? nil : material
        narrativeText = retrievalService.makeNarrativeText(from: material, periodName: "今天")
        if narrativeText.isEmpty {
            narrativeText = fallbackNarrativeParagraph
        }

        if isCommentEnabled {
            requestAIAnalysisIfNeeded(force: forceAIRefresh)
        } else {
            isLoadingAIAnalysis = false
        }
    }

    private func requestAIAnalysisIfNeeded(force: Bool) {
        guard isCommentEnabled else { return }
        guard let material = narrativeMaterial, !material.representativeUnits.isEmpty else {
            aiAnalysisText = ""
            aiAnalysisErrorMessage = aiResponseUnavailableMessage
            isLoadingAIAnalysis = false
            return
        }

        if !force && !aiAnalysisText.isEmpty {
            return
        }

        isLoadingAIAnalysis = true
        aiAnalysisText = force ? "" : aiAnalysisText
        aiAnalysisErrorMessage = nil

        Task {
            do {
                let analysis = try await aiService.analyzeNarrativeMaterial(
                    material,
                    periodName: formattedHeaderDate(day.date),
                    followupQuestion: selectedCommentStyle.followupPrompt
                )
                await MainActor.run {
                    aiAnalysisText = analysis.trimmingCharacters(in: .whitespacesAndNewlines)
                    aiAnalysisErrorMessage = aiAnalysisText.isEmpty ? "AI 这次没有给出可展示的分析。" : nil
                    isLoadingAIAnalysis = false
                }
            } catch {
                await MainActor.run {
                    aiAnalysisText = ""
                    aiAnalysisErrorMessage = "暂时无法生成 AI 回应，先看下面的记录和叙事。"
                    isLoadingAIAnalysis = false
                }
            }
        }
    }

    private var aiResponseUnavailableMessage: String {
        let captures = allCaptures
        guard !captures.isEmpty else {
            return "今天还没有记录。"
        }

        let states = captures.map(\.processingState)
        if states.contains(.splitting) || states.contains(.pendingSplit) || states.contains(.pendingClean) || states.contains(.cleanReady) {
            return "这一天的记录已经保存，还在整理成可分析的结构。完成拆分后会生成 AI 回应。"
        }

        if states.allSatisfy({ $0 == .splitFailed }) {
            return "这一天的记录整理失败了，重新拆分后才能生成 AI 回应。"
        }

        if states.contains(.splitFailed) {
            return "这一天有部分记录整理失败，目前还没有形成足够稳定的 AI 回应材料。"
        }

        return "这一天有记录，但还没有形成可用于 AI 回应的结构化片段。"
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

private struct CaptureRow: Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date
    let processingState: CaptureProcessingState
}

private struct NarrativeSourceRow: Identifiable {
    let id: String
    let sentence: String
    let captureID: UUID
    let createdAt: Date
}

private struct NarrativeUnit {
    let capture: CaptureRow
    let snippet: String
    let dayPartText: String
    var duplicateCount: Int
}

enum CommentStyle: String, CaseIterable, Identifiable {
    case gentle
    case honest
    case action
    case pattern

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle:
            return "温和观察"
        case .honest:
            return "诚实直说"
        case .action:
            return "行动提醒"
        case .pattern:
            return "模式识别"
        }
    }

    var sampleText: String {
        switch self {
        case .gentle:
            return "先把这段记录里的事实放在前面，再轻轻指出可能的联系。"
        case .honest:
            return "更直接地说出这段记录里已经出现的变化，不替你补动机。"
        case .action:
            return "从这段记录里挑出最值得继续观察的一步，而不是给一串建议。"
        case .pattern:
            return "试着从当天片段里看出重复倾向，但保持证据边界。"
        }
    }

    var followupPrompt: String? {
        switch self {
        case .gentle:
            return "请用更温和、更克制的口吻回应，先说事实，再点出轻微但有根据的联系。"
        case .honest:
            return "请更直接一些，但仍然证据约束，不要安慰，不要夸张，只说站得住脚的事实和联系。"
        case .action:
            return "请优先指出这一天里最值得继续观察或采取的小动作，但不要写成说教。"
        case .pattern:
            return "请优先指出这一天和更长期记录之间可能存在的模式线索，但不要虚构因果。"
        }
    }
}
