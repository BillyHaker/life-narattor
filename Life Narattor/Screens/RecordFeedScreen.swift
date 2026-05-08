import CoreData
import SwiftUI
import UIKit

struct RecordFeedScreen: View {
    @StateObject private var viewModel: CaptureFeedViewModel
    @State private var selectedCapture: CaptureItem?
    @State private var selectedSurface: FeedSurface = .record
    @State private var selectedScope: RecordListScope = .today
    @State private var searchQuery: String = ""
    @State private var shouldAutoScrollToLatest: Bool = true
    @State private var isSettingsPresented = false
    @FocusState private var isSearchFieldFocused: Bool
    @FocusState private var isInputFieldFocused: Bool
    private let context: NSManagedObjectContext
    private let aiService: AIService
    private let onShowProductGuide: (() -> Void)?
    private let calendar = Calendar.current
    private let recordListBottomID = "record-list-bottom-anchor"

    init(context: NSManagedObjectContext, aiService: AIService, onShowProductGuide: (() -> Void)? = nil) {
        self.context = context
        self.aiService = aiService
        self.onShowProductGuide = onShowProductGuide
        _viewModel = StateObject(wrappedValue: CaptureFeedViewModel(context: context, aiService: aiService))
    }

    var body: some View {
        NavigationStack {
            contentView
            .onAppear {
                viewModel.activateIfNeeded()
                viewModel.loadCaptures()
                viewModel.inputMode = selectedSurface.inputMode
                if selectedSurface == .assist {
                    viewModel.ensureActiveAssistThread()
                }
            }
            .onChange(of: selectedSurface) { _, surface in
                viewModel.inputMode = surface.inputMode
                shouldAutoScrollToLatest = true
                if surface == .assist {
                    viewModel.ensureActiveAssistThread()
                }
            }
            .onChange(of: selectedScope) { _, _ in
                shouldAutoScrollToLatest = true
            }
            .onChange(of: searchQuery) { _, _ in
                shouldAutoScrollToLatest = true
            }
            .sheet(item: $selectedCapture) { item in
                CaptureDetailSheet(
                    item: item,
                    context: context,
                    aiService: aiService,
                    onRetryClean: { viewModel.retryClean(captureID: $0, forceAI: true) },
                    onRetryTranscription: { viewModel.retryTranscription(captureID: $0) },
                    onRetryAtomization: { viewModel.retryAtomization(captureID: $0) },
                    onCaptureChanged: {
                        viewModel.loadCaptures()
                        if let updated = viewModel.captures.first(where: { $0.id == item.id }) {
                            selectedCapture = updated
                        } else {
                            selectedCapture = nil
                        }
                    }
                )
            }
            .sheet(isPresented: $isSettingsPresented) {
                AppSettingsScreen {
                    isSettingsPresented = false
                    onShowProductGuide?()
                }
            }
            .fullScreenCover(isPresented: assistDraftEditorBinding) {
                if let payload = viewModel.assistDraftPayload {
                    AssistDraftEditorScreen(
                        payload: payload,
                        initialBody: viewModel.assistDraftEditorBodyText(),
                        onContinueDialogue: { title, body in
                            viewModel.saveAssistDraftEdits(title: title, body: body)
                            viewModel.hideAssistDraftCard()
                        },
                        onRegenerate: {
                            viewModel.regenerateAssistDraft()
                        },
                        onConfirmRecord: { title, body in
                            viewModel.commitAssistDraftToRecord(title: title, body: body)
                        }
                    )
                }
            }
            .alert("无法开始录音", isPresented: micPermissionAlertBinding) {
                Button("去设置") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                    viewModel.dismissMicPermissionAlert()
                }
                Button("取消", role: .cancel) {
                    viewModel.dismissMicPermissionAlert()
                }
            } message: {
                Text(viewModel.micPermissionMessage)
            }
            .alert("无法转写语音", isPresented: speechPermissionAlertBinding) {
                Button("去设置") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                    viewModel.dismissSpeechPermissionAlert()
                }
                Button("取消", role: .cancel) {
                    viewModel.dismissSpeechPermissionAlert()
                }
            } message: {
                Text(viewModel.speechPermissionMessage)
            }
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView
            if selectedSurface == .record {
                filterBar
            }

            if let message = viewModel.recordingNoticeMessage {
                recordingNoticeView(message: message, onClose: viewModel.dismissRecordingNotice)
            }

            if selectedSurface == .record, viewModel.isAutoSplitInProgress {
                autoSplitProgressView
            }

            if selectedSurface == .assist {
                assistSessionView
            } else {
                if currentSections.isEmpty {
                    listEmptyStateView
                } else {
                    sectionsScrollView
                }
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            bottomInsetView
        }
    }

    private var sectionsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(currentSections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(formattedSectionDate(section.dayStart))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(section.items.count) 条")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            sectionListContent(for: section)
                        }
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(recordListBottomID)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    dismissKeyboard()
                }
            )
            .onAppear {
                scrollToLatestIfNeeded(with: proxy)
            }
            .onChange(of: selectedScope) { _, _ in
                shouldAutoScrollToLatest = true
                scrollToLatestIfNeeded(with: proxy)
            }
            .onChange(of: currentCaptureIDs) { _, _ in
                scrollToLatestIfNeeded(with: proxy)
            }
        }
    }

    private var bottomInsetView: some View {
        VStack(spacing: 8) {
            if viewModel.isRecording, let startedAt = viewModel.recordingStartedAt {
                RecordingChipView(
                    startedAt: startedAt,
                    level: viewModel.recordingLevel,
                    onStop: viewModel.stopRecording,
                    onCancel: viewModel.cancelRecording
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            } else {
                CaptureInputBarView(
                    text: inputTextBinding,
                    mode: inputModeBinding,
                    onSend: viewModel.addCaptureFromInput,
                    onRecord: viewModel.startRecording,
                    showsModePicker: false,
                    textPlaceholder: inputPlaceholder,
                    isTextFieldFocused: $isInputFieldFocused
                )
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    private var inputTextBinding: Binding<String> {
        Binding(
            get: { viewModel.inputText },
            set: { viewModel.inputText = $0 }
        )
    }

    private var inputModeBinding: Binding<CaptureInputMode> {
        Binding(
            get: { viewModel.inputMode },
            set: { mode in
                let surface: FeedSurface = mode == .assist ? .assist : .record
                selectedSurface = surface
                viewModel.inputMode = mode
                if surface == .assist {
                    viewModel.ensureActiveAssistThread()
                }
            }
        )
    }

    private var micPermissionAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isMicPermissionAlertPresented },
            set: { viewModel.isMicPermissionAlertPresented = $0 }
        )
    }

    private var speechPermissionAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isSpeechPermissionAlertPresented },
            set: { viewModel.isSpeechPermissionAlertPresented = $0 }
        )
    }

    private var assistDraftEditorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isAssistDraftVisible && viewModel.assistDraftPayload != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.hideAssistDraftCard()
                }
            }
        )
    }

    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("今天 · \(formattedDate(Date()))")
                .font(.title2.weight(.semibold))

            Spacer()

            Button {
                dismissKeyboard()
                isSettingsPresented = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("设置")
        }
        .padding(.horizontal, 16)
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if selectedSurface == .record {
                Picker("范围", selection: $selectedScope) {
                    ForEach(RecordListScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(searchPlaceholder, text: $searchQuery)
                    .font(.subheadline)
                    .focused($isSearchFieldFocused)

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
    }

    private var listEmptyStateView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "text.bubble")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(emptyStateMessage)
                .font(.headline)
                .foregroundStyle(.primary)
            Text("可以很短，也可以很碎。先留下这一刻，整理的事之后再说。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }

    private var recordFilteredCaptures: [CaptureItem] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        return viewModel.captures.filter { item in
            guard item.mode == .log else {
                return false
            }
            guard selectedScope.contains(item.createdAt, calendar: calendar) else {
                return false
            }
            guard !query.isEmpty else {
                return true
            }
            return matchesSearch(item: item, query: query)
        }
    }

    private var currentSections: [CaptureSection] {
        let grouped = Dictionary(grouping: recordFilteredCaptures) { item in
            calendar.startOfDay(for: item.createdAt)
        }
        return grouped.map { day, items in
            CaptureSection(dayStart: day, items: items.sorted { $0.createdAt < $1.createdAt })
        }
        .sorted { $0.dayStart < $1.dayStart }
    }

    private var emptyStateMessage: String {
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "没有匹配的记录，试试换个关键词。"
        }
        switch selectedScope {
        case .today:
            return "今天还没有记录。随手记一句就好。"
        case .week:
            return "最近 7 天还没有记录。"
        case .all:
            return "还没有记录。随手记一句就好。"
        }
    }

    private func recordingNoticeView(message: String, onClose: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.secondary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func formattedSectionDate(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "今天"
        }
        if calendar.isDateInYesterday(date) {
            return "昨天"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date)
    }

    private func captureMetaText(for item: CaptureItem) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        let inputText = item.inputType == .voice ? "语音" : "文字"
        return "\(formatter.string(from: item.createdAt)) · \(item.dayPart.title) · \(inputText)"
    }

    private func captureSummaryText(for item: CaptureItem) -> String {
        let cleanedText = item.cleanText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let source = cleanedText.isEmpty ? item.rawText : cleanedText
        let compact = source
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return compact.isEmpty ? "（空记录）" : compact
    }

    private func captureStatusText(for item: CaptureItem) -> String {
        if item.revisionCount > 0 {
            return "已修订 \(item.revisionCount) 次"
        }
        if item.isTranscriptionInProgress {
            return "正在转写…"
        }
        if item.inputType == .voice, let transcriptionStatus = item.transcriptionStatus {
            return transcriptionStatus.displayText
        }

        if item.processingState == .atomsReady || item.processingState == .tagsSuggested {
            return "已整理成 \(item.atomsCount) 个片段"
        }
        return "已记录"
    }

    private var autoSplitProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(
                value: Double(viewModel.autoSplitCompletedCount),
                total: Double(max(viewModel.autoSplitTotalCount, 1))
            )
            Text("正在拆分记录 \(min(viewModel.autoSplitCompletedCount + 1, viewModel.autoSplitTotalCount))/\(viewModel.autoSplitTotalCount)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private func matchesSearch(item: CaptureItem, query: String) -> Bool {
        let searchable = [
            item.rawText,
            item.cleanText ?? "",
            item.transcriptText ?? "",
            item.ackTitle ?? "",
            item.ackDetail ?? ""
        ]
        return searchable.contains { $0.localizedCaseInsensitiveContains(query) }
    }

    private var currentCaptureIDs: [UUID] {
        recordFilteredCaptures.map(\.id)
    }

    private func scrollToLatestIfNeeded(with proxy: ScrollViewProxy) {
        guard shouldAutoScrollToLatest else { return }
        guard !currentCaptureIDs.isEmpty else { return }
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                proxy.scrollTo(recordListBottomID, anchor: .bottom)
                shouldAutoScrollToLatest = false
            }
        }
    }

    private var searchPlaceholder: String {
        "找一句记过的话或线索"
    }

    private var inputPlaceholder: String {
        selectedSurface == .record ? "记一句当下发生的事或想法…" : "告诉助手你想梳理什么…"
    }

    @ViewBuilder
    private func sectionListContent(for section: CaptureSection) -> some View {
        ForEach(section.items) { item in
            CompactCaptureRow(
                item: item,
                metaText: captureMetaText(for: item),
                summaryText: captureSummaryText(for: item),
                statusText: captureStatusText(for: item),
                onTap: { selectedCapture = item },
                onRetryTranscription: { viewModel.retryTranscription(captureID: item.id) }
            )
            .id(item.id)
        }
    }

    private var assistSessionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            assistThreadToolbar

            if let splitSuggestion = viewModel.assistSplitSuggestionMessage, !splitSuggestion.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(splitSuggestion)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("拆分") {
                        viewModel.requestAssistThreadSplit()
                    }
                    .font(.footnote.weight(.semibold))
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    Button("忽略") {
                        viewModel.dismissAssistSplitSuggestion()
                    }
                    .font(.footnote)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
            }

            if !viewModel.assistSessionMessages.isEmpty || viewModel.assistDraftPayload != nil {
                HStack(spacing: 8) {
                    Button("整理为记录") {
                        viewModel.showAssistDraftCard()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(viewModel.assistSessionMessages.isEmpty || viewModel.isAssistGenerating)

                    if viewModel.assistDraftPayload != nil {
                        Button("重新整理") {
                            viewModel.regenerateAssistDraft()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }

            if viewModel.assistSessionMessages.isEmpty,
               viewModel.assistDraftPayload == nil,
               !viewModel.isAssistGenerating {
                VStack(alignment: .leading, spacing: 8) {
                    Text("这是一个新的助手会话")
                        .font(.headline)
                    Text("先聊清楚，再点“记录到记录页”。确认后会自动清空当前会话，开启下一轮。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.assistSessionMessages) { message in
                                AssistSessionBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isAssistGenerating {
                                HStack {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("助手处理中…")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("assist-typing")
                            }

                            if let error = viewModel.assistDraftErrorMessage, !error.isEmpty {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id("assist-error")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .onAppear {
                        scrollAssistSessionToBottom(with: proxy)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            dismissKeyboard()
                        }
                    )
                    .onChange(of: viewModel.assistSessionMessages.count) { _, _ in
                        scrollAssistSessionToBottom(with: proxy)
                    }
                    .onChange(of: viewModel.isAssistGenerating) { _, _ in
                        scrollAssistSessionToBottom(with: proxy)
                    }
                }
            }
        }
    }

    private var assistThreadToolbar: some View {
        HStack(spacing: 10) {
            Text("当前窗口：\(viewModel.activeAssistThreadTitle)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Menu("窗口") {
                ForEach(viewModel.assistThreads) { thread in
                    Button(threadMenuTitle(thread)) {
                        viewModel.openAssistThread(thread.id)
                    }
                }
            }
            .font(.footnote)

            Button("新建窗口") {
                viewModel.requestAssistThreadSplit()
            }
            .font(.footnote.weight(.semibold))
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
        .padding(.horizontal, 16)
    }

    private func threadMenuTitle(_ thread: AssistThreadSummary) -> String {
        let state = thread.status == .active ? "进行中" : "已关闭"
        return "\(thread.title) · \(state) · \(thread.linkedCaptureIDs.count)条记录"
    }

    private func scrollAssistSessionToBottom(with proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if viewModel.assistDraftPayload != nil {
                if viewModel.isAssistDraftVisible {
                    proxy.scrollTo("assist-draft-card", anchor: .bottom)
                } else if let last = viewModel.assistSessionMessages.last?.id {
                    proxy.scrollTo(last, anchor: .bottom)
                }
            } else if viewModel.isAssistGenerating {
                proxy.scrollTo("assist-typing", anchor: .bottom)
            } else if let last = viewModel.assistSessionMessages.last?.id {
                proxy.scrollTo(last, anchor: .bottom)
            }
        }
    }

    private func dismissKeyboard() {
        isSearchFieldFocused = false
        isInputFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct CompactCaptureRow: View {
    let item: CaptureItem
    let metaText: String
    let summaryText: String
    let statusText: String
    let onTap: () -> Void
    let onRetryTranscription: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(metaText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            Text(summaryText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                if !item.isTranscriptionInProgress,
                   (item.transcriptionStatus == .failed || item.transcriptionStatus == .offline) && item.inputType == .voice {
                    Button("重试", action: onRetryTranscription)
                        .font(.caption2.weight(.semibold))
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

private struct AssistSessionBubble: View {
    let message: AssistSessionMessage

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bubble: some View {
        Group {
            if let rendered = renderedMarkdown {
                Text(rendered)
            } else {
                Text(message.text)
            }
        }
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(message.role == .assistant ? Color(.systemBackground) : Color.blue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var renderedMarkdown: AttributedString? {
        guard message.role == .assistant else { return nil }
        return try? AttributedString(
            markdown: message.text,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        )
    }
}

private struct CaptureSection: Identifiable {
    let dayStart: Date
    let items: [CaptureItem]
    var id: Date { dayStart }
}

private enum RecordListScope: String, CaseIterable, Identifiable {
    case today
    case week
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "今天"
        case .week:
            return "近7天"
        case .all:
            return "全部"
        }
    }

    func contains(_ date: Date, calendar: Calendar) -> Bool {
        switch self {
        case .today:
            return calendar.isDateInToday(date)
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: Date()) else {
                return true
            }
            return date >= calendar.startOfDay(for: weekAgo)
        case .all:
            return true
        }
    }
}

private enum FeedSurface: String, CaseIterable, Identifiable {
    case record
    case assist

    var id: String { rawValue }

    var title: String {
        switch self {
        case .record:
            return "记录"
        case .assist:
            return "助手"
        }
    }

    var inputMode: CaptureInputMode {
        switch self {
        case .record:
            return .log
        case .assist:
            return .assist
        }
    }
}

struct RecordFeedScreen_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        SamplePreviewData.seedCaptures(in: context)
        return RecordFeedScreen(context: context, aiService: UnavailableAIService())
    }
}

private enum SamplePreviewData {
    static func seedCaptures(in context: NSManagedObjectContext) {
        let now = Date()
        let calendar = Calendar.current

        let samples: [(String, String, String, DayPart, Int, Int16, CaptureProcessingState)] = [
            ("早上开会做了进度对齐", "✅ 已记下", "确认：开会 + 进度", .morning, -2, 2, .atomsReady),
            ("午饭后散步十分钟", "✅ 已记下", "确认：散步 + 放松", .afternoon, -5, 0, .cleanReady)
        ]

        for (index, sample) in samples.enumerated() {
            let entity = CaptureEntity(context: context)
            entity.id = UUID()
            entity.createdAt = calendar.date(byAdding: .hour, value: sample.4, to: now) ?? now
            entity.rawText = sample.0
            entity.cleanText = sample.0
            entity.ackTitle = sample.1
            entity.ackDetail = sample.2
            entity.dayPart = sample.3.rawValue
            entity.mode = CaptureInputMode.log.rawValue
            entity.atomsCount = sample.5
            entity.processingState = sample.6.rawValue
            entity.inputType = CaptureInputType.text.rawValue

            if index == 0, sample.5 > 0 {
                var firstAtomID: UUID?
                for order in 0..<Int(sample.5) {
                    let atom = AtomEntity(context: context)
                    atom.id = UUID()
                    if firstAtomID == nil { firstAtomID = atom.id }
                    atom.captureID = entity.id
                    atom.type = AtomType.event.rawValue
                    atom.content = order == 0 ? "开会做了进度对齐" : "同步了下一步安排"
                    atom.orderInCapture = Int16(order)
                    atom.isKey = false
                    atom.createdAt = now
                    atom.startChar = -1
                    atom.endChar = -1
                    atom.atomizeVersion = "preview_v1"
                }

                if let firstAtomID {
                    let tag = TagEntity(context: context)
                    tag.id = UUID()
                    tag.name = "项目A"
                    tag.type = TagType.project.rawValue
                    tag.isUserVisible = true
                    tag.isCommon = true
                    tag.createdAt = now

                    let link = AtomTagEntity(context: context)
                    link.id = UUID()
                    link.atomID = firstAtomID
                    link.tagID = tag.id
                    link.createdAt = now
                    link.isSuggested = false
                }
            }
        }

        let assistEntity = CaptureEntity(context: context)
        assistEntity.id = UUID()
        assistEntity.createdAt = calendar.date(byAdding: .hour, value: -9, to: now) ?? now
        assistEntity.rawText = "想把 fine / fan / find 的区别整理成练习点"
        assistEntity.cleanText = assistEntity.rawText
        assistEntity.dayPart = DayPart.evening.rawValue
        assistEntity.mode = CaptureInputMode.assist.rawValue
        assistEntity.atomsCount = 0
        assistEntity.processingState = CaptureProcessingState.cleanReady.rawValue
        assistEntity.inputType = CaptureInputType.text.rawValue

        let payload = AssistArchivePayload(
            reply: "我明白了，你想把发音区别整理成可练习的记录。",
            card: AssistArchiveCard(
                title: "fine / fan / find 发音区分",
                context: "容易混淆三个词的元音与结尾。",
                keyPoints: [
                    "fan 是 /æ/（像 cat 的元音）",
                    "fine 是 /aɪ/（有明显滑音）",
                    "find 是 /aɪ/ + 词尾 /d/"
                ],
                nextSteps: ["做 3 分钟最小对比练习：fan–fine–find"],
                tagSuggestions: [AssistTagSuggestion(tagType: "theme", name: "English pronunciation", score: 0.72)],
                confidence: "medium"
            ),
            turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 1)
        )

        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = "assist_archive_card"
        artifact.title = payload.card.title
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.sourceCaptureID = assistEntity.id
        artifact.status = AssistArchiveStatus.draft.rawValue
        artifact.createdAt = now
        artifact.updatedAt = now

        let voiceEntity = CaptureEntity(context: context)
        voiceEntity.id = UUID()
        voiceEntity.createdAt = calendar.date(byAdding: .minute, value: -30, to: now) ?? now
        voiceEntity.rawText = "语音记录"
        voiceEntity.cleanText = "（占位）这是一段语音转写内容。"
        voiceEntity.dayPart = DayPart.afternoon.rawValue
        voiceEntity.mode = CaptureInputMode.log.rawValue
        voiceEntity.atomsCount = 0
        voiceEntity.processingState = CaptureProcessingState.cleanReady.rawValue
        voiceEntity.inputType = CaptureInputType.voice.rawValue
        voiceEntity.transcriptionStatus = TranscriptionStatus.completed.rawValue
        voiceEntity.transcriptText = "（占位）这是一段语音转写内容。"

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
