import AVFoundation
import Combine
import CoreData
import SwiftUI
import UIKit

struct CaptureDetailSheet: View {
    let item: CaptureItem
    let context: NSManagedObjectContext
    let aiService: AIService
    let onRetryClean: ((UUID) -> Void)?
    let onRetryTranscription: ((UUID) -> Void)?
    let onRetryAtomization: ((UUID) -> Void)?
    let onCaptureChanged: (() -> Void)?

    init(
        item: CaptureItem,
        context: NSManagedObjectContext,
        aiService: AIService = AIServiceFactory.make(),
        onRetryClean: ((UUID) -> Void)? = nil,
        onRetryTranscription: ((UUID) -> Void)? = nil,
        onRetryAtomization: ((UUID) -> Void)? = nil,
        onCaptureChanged: (() -> Void)? = nil
    ) {
        self.item = item
        self.context = context
        self.aiService = aiService
        self.onRetryClean = onRetryClean
        self.onRetryTranscription = onRetryTranscription
        self.onRetryAtomization = onRetryAtomization
        self.onCaptureChanged = onCaptureChanged
        _currentProcessingState = State(initialValue: item.processingState)
        _currentAtomizationError = State(initialValue: item.atomizationErrorReason)
        _currentCleanText = State(initialValue: item.cleanText ?? item.rawText)
        _currentTranscriptText = State(initialValue: item.transcriptText)
        _currentTranscriptionStatus = State(initialValue: item.transcriptionStatus)
        _currentTranscriptionError = State(initialValue: item.transcriptionErrorReason)
    }

    @State private var selectedTab: CaptureDetailTab = .cleaned
    @State private var showingTagSheet = false
    @State private var selectedAtom: AtomItem?
    @State private var selectedTag: TagItem?
    @State private var atoms: [AtomItem] = []
    @State private var isAtomizing = false
    @State private var atomizeError: String? = nil
    @State private var atomizeTask: Task<Void, Never>? = nil
    @StateObject private var audioPlayer = AudioPlaybackController()
    @State private var highlightedSourceRange: Range<Int>? = nil
    @State private var showingSourceHighlight = false
    @State private var currentProcessingState: CaptureProcessingState
    @State private var currentAtomizationError: String?
    @State private var currentCleanText: String
    @State private var currentTranscriptText: String?
    @State private var currentTranscriptionStatus: TranscriptionStatus?
    @State private var currentTranscriptionError: String?
    @State private var isRetryingTranscription = false
    @State private var currentAtomizationPayload: AtomizationArtifactPayload?
    @State private var currentAtomizationStatusMessage: String?
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingFeedback = false
    @State private var isDeleting = false
    @Environment(\.dismiss) private var dismiss

    private var atomStore: AtomTagStore { AtomTagStore(context: context) }
    private var atomizationCoordinator: AtomizationCoordinator {
        AtomizationCoordinator(context: context, aiService: aiService)
    }
    private var recordUnits: [AssistRecordUnit] {
        item.assistRecord?.payload.card.effectiveRecordUnits ?? []
    }
    private var atomizedRecordUnits: [RecordUnitDraft] {
        currentAtomizationPayload?.recordUnits ?? []
    }


    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("内容", selection: $selectedTab) {
                    ForEach(CaptureDetailTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    switch selectedTab {
                    case .cleaned:
                        if item.inputType == .voice, currentCleanText == item.rawText, currentTranscriptText == nil {
                            Text(transcriptionPlaceholderText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(currentCleanText)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    case .raw:
                        VStack(alignment: .leading, spacing: 12) {
                            if item.inputType == .voice {
                                if let audioURL = audioURL {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 12) {
                                            Button {
                                                if audioPlayer.isPlaying {
                                                    audioPlayer.pause()
                                                } else {
                                                    audioPlayer.play(url: audioURL)
                                                }
                                            } label: {
                                                Label(
                                                    audioPlayer.isPlaying ? "暂停" : "播放",
                                                    systemImage: audioPlayer.isPlaying ? "pause.fill" : "play.fill"
                                                )
                                            }
                                            .buttonStyle(.borderedProminent)

                                            Button {
                                                audioPlayer.stop()
                                                audioPlayer.play(url: audioURL)
                                            } label: {
                                                Label("重播", systemImage: "gobackward")
                                            }
                                            .buttonStyle(.bordered)
                                            .disabled(audioPlayer.duration <= 0)
                                        }

                                        Slider(
                                            value: Binding(
                                                get: { audioPlayer.currentTime },
                                                set: { audioPlayer.scrub(to: $0) }
                                            ),
                                            in: 0...max(audioPlayer.duration, 1),
                                            onEditingChanged: { editing in
                                                if editing {
                                                    audioPlayer.beginScrubbing()
                                                } else {
                                                    audioPlayer.endScrubbing()
                                                }
                                            }
                                        )
                                        .disabled(audioPlayer.duration <= 0)

                                        HStack {
                                            Text(audioPlayer.currentTimeText)
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                            Text(audioPlayer.durationText)
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .onAppear {
                                        audioPlayer.load(url: audioURL)
                                    }
                                } else {
                                    Text("暂无音频")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }

                                if let status = currentTranscriptionStatus {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(isRetryingTranscription ? "正在转写…" : status.displayText)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)

                                        if !isRetryingTranscription,
                                           (status == .failed || status == .offline),
                                           let reason = currentTranscriptionError,
                                           !reason.isEmpty {
                                            Text(reason)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }

                                if let transcript = currentTranscriptText {
                                    Text(transcript)
                                        .font(.body)
                                        .foregroundStyle(.primary)

                                    Button("复制转写") {
                                        UIPasteboard.general.string = transcript
                                    }
                                    .font(.footnote.weight(.semibold))
                                } else {
                                    Text(transcriptionPlaceholderText)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text(item.rawText)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                    case .atoms:
                        atomsView
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(16)
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("编辑") {
                        showingEditSheet = true
                    }
                    .font(.body.weight(.semibold))

                    Button("隐藏") {
                        hideCapture()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .disabled(isDeleting)

                    Button("删除") {
                        showingDeleteConfirmation = true
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.red.opacity(0.86))
                    .disabled(isDeleting)
                }

                if recordUnits.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        if selectedTab == .atoms {
                            Button("重新拆分") {
                                ensureAtomsIfNeeded(force: true)
                            }
                        } else if selectedTab == .cleaned, let onRetryClean {
                            Button("重新整理") {
                                onRetryClean(item.id)
                                refreshProcessingState()
                            }
                        } else if selectedTab == .raw, item.inputType == .voice, let onRetryTranscription {
                            Button("重新转写") {
                                isRetryingTranscription = true
                                onRetryTranscription(item.id)
                            }
                        } else if selectedTab == .raw {
                            EmptyView()
                        } else {
                            Button("添加标签") {
                                showingTagSheet = true
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTagSheet) {
                AddTagSheet(context: context, atomID: selectedAtom?.id, onSaved: reloadAtoms)
            }
            .sheet(isPresented: $showingEditSheet) {
                CaptureEditSheet(
                    initialText: editableText,
                    onCancel: { showingEditSheet = false },
                    onSave: { updatedText in
                        saveEditedCapture(text: updatedText)
                    }
                )
            }
            .sheet(item: $selectedAtom) { atom in
                AtomDetailSheet(atom: atom, context: context, onSaved: reloadAtoms)
            }
            .sheet(item: $selectedTag) { tag in
                NavigationStack {
                    SearchScreen(initialQuery: tag.name, initialFilter: SearchFilterType.from(tagType: tag.type))
                }
            }
            .sheet(isPresented: $showingSourceHighlight) {
                sourceHighlightSheet
            }
            .sheet(isPresented: $showingFeedback) {
                NavigationStack {
                    FeedbackScreen()
                }
            }
            .confirmationDialog(
                "删除这条记录？",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) {
                    deleteCapture()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("删除后，这条记录以及相关拆分和整理结果会一起移除。")
            }
            .onReceive(NotificationCenter.default.publisher(for: .captureProcessingStateChanged)) { notification in
                guard let changedID = notification.userInfo?["captureID"] as? UUID,
                      changedID == item.id else { return }
                if let statusMessage = notification.userInfo?["atomizationStatusMessage"] as? String {
                    currentAtomizationStatusMessage = statusMessage
                }
                refreshProcessingState()
                reloadAtoms()
            }
            .task {
                await MainActor.run {
                    reloadAtoms()
                    refreshProcessingState()
                }
            }
            .onDisappear {
                atomizeTask?.cancel()
                atomizeTask = nil
                audioPlayer.stop()
            }
        }
    }

    private var audioURL: URL? {
        guard let path = item.audioPath, !path.isEmpty else { return nil }
        let url = URL(fileURLWithPath: path)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    private var editableText: String {
        currentCleanText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? item.rawText : currentCleanText
    }

    private var transcriptionPlaceholderText: String {
        if isRetryingTranscription {
            return "转写中，请稍候"
        }
        switch currentTranscriptionStatus {
        case .failed:
            return "转写失败，请重试"
        case .offline:
            return "离线中，稍后自动转写"
        default:
            return "转写中…"
        }
    }

    private var atomsView: some View {
        VStack(alignment: .leading, spacing: 12) {


            if !recordUnits.isEmpty {
                assistRecordUnitsView
            } else if !atomizedRecordUnits.isEmpty {
                atomizedRecordUnitsView
            } else if isAtomizing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(currentAtomizationStatusMessage ?? "正在拆分…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let atomizeError {
                HStack(spacing: 8) {
                    Text(atomizeError)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("重试") {
                        ensureAtomsIfNeeded(force: true)
                    }
                    .font(.footnote.weight(.semibold))
                    Button("反馈") {
                        showingFeedback = true
                    }
                    .font(.footnote.weight(.semibold))
                }
            } else if atoms.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(emptyAtomStateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if recordUnits.isEmpty {
                        Button("重新拆分") {
                            ensureAtomsIfNeeded(force: true)
                        }
                        .font(.footnote.weight(.semibold))
                    }
                    if currentProcessingState == .splitFailed {
                        Button("反馈问题") {
                            showingFeedback = true
                        }
                        .font(.footnote.weight(.semibold))
                    }
                }
            } else {


                ForEach(atoms) { atom in
                    CaptureAtomRowView(
                        atom: atom,
                        onOpenDetail: {
                            selectedAtom = atom
                        },
                        onAddTag: {
                            selectedAtom = atom
                            showingTagSheet = true
                        },
                        onTagTap: { tag in
                            selectedTag = tag
                        },
                        onMarkAsKey: {
                            atomStore.markAsKey(atomID: atom.id)
                            reloadAtoms()
                        },
                        onDelete: {
                            atomStore.deleteAtom(atomID: atom.id)
                            reloadAtoms()
                        },
                        onShowSource: {
                            showSource(for: atom)
                        },
                        showsSourceButton: sourceRange(for: atom) != nil
                    )
                }
            }
        }
    }

    private var assistRecordUnitsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(recordUnits.enumerated()), id: \.offset) { index, unit in
                AssistRecordUnitRowView(
                    index: index + 1,
                    unit: unit
                )
            }
        }
    }

    private var atomizedRecordUnitsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(atomizedRecordUnits.enumerated()), id: \.offset) { index, unit in
                RecordUnitDraftRowView(
                    index: index + 1,
                    unit: unit,
                    onShowSource: {
                        showSource(for: unit)
                    },
                    showsSourceButton: sourceRange(for: unit) != nil
                )
            }
        }
    }

    @MainActor
    private func ensureAtomsIfNeeded(force: Bool = false) {
        guard let cleanText = item.cleanText else { return }
        guard force || item.atomsCount == 0 else { return }
        guard force || !isAtomizing else { return }

        atomizeTask?.cancel()

        // CRITICAL: Atomization now runs on background thread (see AtomizationCoordinator)
        // This prevents UI freeze during AI calls (5-30 seconds)
        atomizeTask = Task { @MainActor in
            isAtomizing = true
            atomizeError = nil

            if let onRetryAtomization {
                currentProcessingState = .splitting
                currentAtomizationError = nil
                currentAtomizationStatusMessage = "已发送拆分请求…"
                onRetryAtomization(item.id)
                refreshProcessingState()
            } else {
                do {
                    currentProcessingState = .splitting
                    currentAtomizationError = nil
                    currentAtomizationStatusMessage = "已发送拆分请求…"
                    try await atomizationCoordinator.atomizeCaptureIfNeeded(
                        captureID: item.id,
                        cleanText: cleanText,
                        progress: { message in
                            currentAtomizationStatusMessage = message
                        }
                    )
                } catch {
                    atomizeError = "拆分失败，请稍后重试"
                }
            }
            guard !Task.isCancelled else { return }

            reloadAtoms()
            refreshProcessingState()
            isAtomizing = false
            atomizeTask = nil
        }
    }

    @MainActor
    private func reloadAtoms() {
        atoms = atomStore.fetchAtoms(captureID: item.id)
    }



    @MainActor
    private func refreshProcessingState() {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }
        currentProcessingState = CaptureProcessingState(rawValue: entity.processingState ?? "") ?? item.processingState
        currentAtomizationError = entity.atomizationError
        currentCleanText = entity.cleanText ?? entity.rawText
        currentTranscriptText = entity.transcriptText
        currentTranscriptionStatus = TranscriptionStatus(rawValue: entity.transcriptionStatus ?? "")
        currentTranscriptionError = entity.transcriptionError
        currentAtomizationPayload = fetchAtomizationPayload(captureID: item.id)
        if currentProcessingState != .splitting {
            currentAtomizationStatusMessage = nil
        }
        if currentTranscriptText != nil || currentTranscriptionStatus == .failed || currentTranscriptionStatus == .offline {
            isRetryingTranscription = false
        }
    }

    private func fetchAtomizationPayload(captureID: UUID) -> AtomizationArtifactPayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            "atomization_payload",
            captureID as CVarArg
        )
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AtomizationArtifactPayload.decode(from: artifact.contentJSON)
    }

    @MainActor
    private func saveEditedCapture(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }

        entity.cleanText = trimmed
        if entity.inputType == CaptureInputType.text.rawValue {
            entity.rawText = trimmed
        }
        if entity.inputType == CaptureInputType.voice.rawValue {
            entity.transcriptText = trimmed
        }
        entity.processingState = CaptureProcessingState.pendingSplit.rawValue
        entity.atomizationError = nil
        entity.atomsCount = 0

        clearCaptureAtoms(captureID: item.id)
        clearCaptureArtifacts(captureID: item.id)

        do {
            try context.save()
            currentCleanText = trimmed
            currentTranscriptText = entity.transcriptText
            currentProcessingState = .pendingSplit
            currentAtomizationError = nil
            currentAtomizationPayload = nil
            atoms = []
            showingEditSheet = false
            onCaptureChanged?()
        } catch {
            context.rollback()
        }
    }

    @MainActor
    private func hideCapture() {
        guard !isDeleting else { return }
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }

        entity.isHiddenFromFeed = true

        do {
            try context.save()
            onCaptureChanged?()
            dismiss()
        } catch {
            context.rollback()
        }
    }

    @MainActor
    private func deleteCapture() {
        guard !isDeleting else { return }
        isDeleting = true
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        guard let entity = try? context.fetch(request).first else {
            isDeleting = false
            return
        }

        clearCaptureAtoms(captureID: item.id)
        clearCaptureArtifacts(captureID: item.id)
        context.delete(entity)

        do {
            try context.save()
            onCaptureChanged?()
            dismiss()
        } catch {
            context.rollback()
        }
        isDeleting = false
    }

    private func clearCaptureAtoms(captureID: UUID) {
        let atomRequest = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        atomRequest.predicate = NSPredicate(format: "captureID == %@", captureID as CVarArg)
        let atoms = (try? context.fetch(atomRequest)) ?? []
        let atomIDs = atoms.map(\.id)

        if !atomIDs.isEmpty {
            let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
            linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)
            let links = (try? context.fetch(linkRequest)) ?? []
            links.forEach { context.delete($0) }
        }

        atoms.forEach { context.delete($0) }
    }

    private func clearCaptureArtifacts(captureID: UUID) {
        let artifactRequest = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        artifactRequest.predicate = NSPredicate(format: "sourceCaptureID == %@", captureID as CVarArg)
        let artifacts = (try? context.fetch(artifactRequest)) ?? []
        artifacts.forEach { context.delete($0) }
    }

    private var emptyAtomStateText: String {
        switch currentProcessingState {
        case .pendingSplit:
            return currentAtomizationError ?? "当前未拆分。"
        case .splitting:
            return currentAtomizationStatusMessage ?? "正在拆分…"
        case .splitFailed:
            return currentAtomizationError ?? "拆分失败。"
        default:
            return "没有可拆分的信息"
        }
    }

    private var sourceHighlightSheet: some View {
        NavigationStack {
            ScrollView {
                if let cleanText = item.cleanText,
                   let range = highlightedSourceRange,
                   let highlightedText = buildHighlightedText(text: cleanText, range: range) {
                    Text(highlightedText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("来源数据不完整")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .navigationTitle("整理后（来源）")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        showingSourceHighlight = false
                    }
                }
            }
        }
    }

    private func showSource(for atom: AtomItem) {
        guard let range = sourceRange(for: atom) else { return }
        highlightedSourceRange = range
        showingSourceHighlight = true
    }

    private func showSource(for unit: RecordUnitDraft) {
        guard let range = sourceRange(for: unit) else { return }
        highlightedSourceRange = range
        showingSourceHighlight = true
    }

    private func sourceRange(for atom: AtomItem) -> Range<Int>? {
        guard let startChar = atom.startChar,
              let endChar = atom.endChar,
              startChar >= 0,
              endChar > startChar else {
            return nil
        }
        return startChar..<endChar
    }

    private func sourceRange(for unit: RecordUnitDraft) -> Range<Int>? {
        guard let startChar = unit.startChar,
              let endChar = unit.endChar,
              startChar >= 0,
              endChar > startChar else {
            return nil
        }
        return startChar..<endChar
    }

    private func buildHighlightedText(text: String, range: Range<Int>) -> AttributedString? {
        guard range.lowerBound >= 0,
              range.upperBound > range.lowerBound,
              range.upperBound <= text.count else {
            return nil
        }

        var attributed = AttributedString(text)
        let start = text.index(text.startIndex, offsetBy: range.lowerBound)
        let end = text.index(text.startIndex, offsetBy: range.upperBound)
        guard let attributedStart = AttributedString.Index(start, within: attributed),
              let attributedEnd = AttributedString.Index(end, within: attributed) else {
            return nil
        }

        attributed[attributedStart..<attributedEnd].backgroundColor = .yellow.opacity(0.35)
        attributed[attributedStart..<attributedEnd].font = .body.bold()
        return attributed
    }
}

final class AudioPlaybackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var currentURL: URL?
    private var progressTimer: AnyCancellable?
    private var isScrubbing = false

    deinit {
        progressTimer?.cancel()
    }

    var currentTimeText: String { Self.formatTime(currentTime) }
    var durationText: String { Self.formatTime(duration) }

    func load(url: URL) {
        _ = preparePlayerIfNeeded(url: url)
    }

    func play(url: URL) {
        guard preparePlayerIfNeeded(url: url) else {
            return
        }
        player?.play()
        isPlaying = true
        startProgressTimer()
        syncProgressFromPlayer()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        syncProgressFromPlayer()
    }

    func stop() {
        player?.stop()
        player = nil
        currentURL = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        isScrubbing = false
        progressTimer?.cancel()
        progressTimer = nil
    }

    func beginScrubbing() {
        isScrubbing = true
    }

    func scrub(to time: TimeInterval) {
        guard let player else {
            currentTime = max(0, time)
            return
        }
        let clamped = min(max(0, time), player.duration)
        player.currentTime = clamped
        currentTime = clamped
    }

    func endScrubbing() {
        isScrubbing = false
        syncProgressFromPlayer()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        syncProgressFromPlayer()
        progressTimer?.cancel()
        progressTimer = nil
    }

    private func preparePlayerIfNeeded(url: URL) -> Bool {
        if currentURL == url, player != nil {
            syncProgressFromPlayer()
            return true
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            currentURL = url
            syncProgressFromPlayer()
            return true
        } catch {
            isPlaying = false
            currentTime = 0
            duration = 0
            player = nil
            currentURL = nil
            return false
        }
    }

    private func startProgressTimer() {
        progressTimer?.cancel()
        progressTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.syncProgressFromPlayer()
            }
    }

    private func syncProgressFromPlayer() {
        guard let player else { return }
        duration = max(0, player.duration)
        if !isScrubbing {
            currentTime = min(max(0, player.currentTime), duration)
        }
        if !player.isPlaying {
            isPlaying = false
        }
    }

    private static func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum CaptureDetailTab: String, CaseIterable, Identifiable {
    case cleaned
    case raw
    case atoms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cleaned:
            return "整理后"
        case .raw:
            return "原始"
        case .atoms:
            return "拆分"
        }
    }
}

struct AssistRecordUnitRowView: View {
    let index: Int
    let unit: AssistRecordUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("分化 \(index)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(unit.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            if !unit.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(unit.summary)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            if !unit.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("要点")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(unit.keyPoints, id: \.self) { point in
                        Text("• \(point)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !unit.nextSteps.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("下一步")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(unit.nextSteps, id: \.self) { step in
                        Text("• \(step)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct RecordUnitDraftRowView: View {
    let index: Int
    let unit: RecordUnitDraft
    let onShowSource: () -> Void
    let showsSourceButton: Bool

    private var visibleAttributes: [RecordUnitAttribute] {
        unit.contextAttributes.filter {
            let name = $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = $0.value.trimmingCharacters(in: .whitespacesAndNewlines)
            return !name.isEmpty && !value.isEmpty && !unit.summary.contains(value)
        }
    }

    private var visibleBehavioralChain: [String] {
        unit.behavioralChain
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !unit.summary.contains($0) }
    }

    private var visibleResults: [String] {
        unit.resultOrState
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !unit.summary.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("事项 \(index)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if showsSourceButton {
                    Button("来源", action: onShowSource)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(unit.summary)
                .font(.body)
                .foregroundStyle(.primary)

            if !visibleAttributes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("上下文")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Array(visibleAttributes.enumerated()), id: \.offset) { _, attribute in
                        Text("\(attribute.name)：\(attribute.value)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !visibleBehavioralChain.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("过程")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Array(visibleBehavioralChain.enumerated()), id: \.offset) { _, step in
                        Text("• \(step)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !visibleResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("结果")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Array(visibleResults.enumerated()), id: \.offset) { _, value in
                        Text("• \(value)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CaptureAtomRowView: View {
    let atom: AtomItem
    let onOpenDetail: () -> Void
    let onAddTag: () -> Void
    let onTagTap: (TagItem) -> Void
    let onMarkAsKey: () -> Void
    let onDelete: () -> Void
    let onShowSource: () -> Void
    let showsSourceButton: Bool

    private var confirmedTags: [TagItem] { atom.tags }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Spacer()
                Menu {
                    Button("添加标签", action: onAddTag)
                    Button("标记为重点", action: onMarkAsKey)
                    Button("删除", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }

            Text(atom.content)
                .font(.body)

            if !confirmedTags.isEmpty {
                ConfirmedTagsRow(tags: confirmedTags, onTagTap: onTagTap)
            }

            if showsSourceButton {
                HStack {
                    Spacer()
                    Button("来源", action: onShowSource)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(perform: onOpenDetail)
    }
}

private struct CaptureEditSheet: View {
    @State private var text: String
    let onCancel: () -> Void
    let onSave: (String) -> Void

    init(initialText: String, onCancel: @escaping () -> Void, onSave: @escaping (String) -> Void) {
        _text = State(initialValue: initialText)
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("修改后的内容会作为当前记录正文保留下来，原始输入仍会保留。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .font(.body)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(16)
            .navigationTitle("编辑记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        onSave(text)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ConfirmedTagsRow: View {
    let tags: [TagItem]
    let onTagTap: (TagItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("已保留标签")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    Button {
                        onTagTap(tag)
                    } label: {
                        Text(tag.name)
                            .font(.caption)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}



struct CaptureDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController(inMemory: true).container.viewContext

        let capture = CaptureEntity(context: context)
        capture.id = UUID()
        capture.createdAt = Date()
        capture.rawText = "我今天开会很烦，明天要整理思路"
        capture.cleanText = "我今天开会很烦，明天要整理思路"
        capture.atomsCount = 2
        capture.processingState = "atomsReady"
        capture.inputType = "text"

        let atom1 = AtomEntity(context: context)
        atom1.id = UUID()
        atom1.captureID = capture.id
        atom1.type = "event"
        atom1.content = "今天开会"
        atom1.orderInCapture = 0
        atom1.isKey = false
        atom1.createdAt = Date()
        atom1.startChar = 2
        atom1.endChar = 6
        atom1.atomizeVersion = "atom_v1"

        let atom2 = AtomEntity(context: context)
        atom2.id = UUID()
        atom2.captureID = capture.id
        atom2.type = "feeling"
        atom2.content = "很烦"
        atom2.orderInCapture = 1
        atom2.isKey = false
        atom2.createdAt = Date()
        atom2.startChar = 6
        atom2.endChar = 8
        atom2.atomizeVersion = "atom_v1"

        try? context.save()

        let item = CaptureItem(
            id: capture.id,
            createdAt: capture.createdAt,
            rawText: capture.rawText,
            cleanText: capture.cleanText,
            ackTitle: nil,
            ackDetail: nil,
            dayPart: .morning,
            mode: .log,
            assistRecord: nil,
            atomsCount: 2,
            processingState: .atomsReady,
            inputType: .text,
            audioPath: nil,
            transcriptText: nil,
            transcriptionStatus: nil,
            isTranscriptionActive: false
        )

        return CaptureDetailSheet(
            item: item,
            context: context,
            aiService: UnavailableAIService()
        )
    }
}

private func tagDisplayText(_ tag: TagItem) -> String {
    guard let badge = tag.suggestionBadgeText else { return tag.name }
    return "\(tag.name) · \(badge)"
}

private func tagDisplayBackground(_ tag: TagItem) -> Color {
    guard tag.isSuggested else { return Color(.systemGray6) }
    return tag.isUserVisible ? Color(.systemGray5) : Color(red: 0.92, green: 0.95, blue: 1.0)
}
