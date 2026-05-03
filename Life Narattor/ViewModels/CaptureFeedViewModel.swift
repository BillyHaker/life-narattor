import AVFoundation
import Combine
import CoreData
import Foundation
import Network
import UIKit

@MainActor
final class CaptureFeedViewModel: ObservableObject {
    @Published var captures: [CaptureItem] = []
    @Published var inputText: String = ""
    @Published var inputMode: CaptureInputMode = .log
    @Published var assistSessionMessages: [AssistSessionMessage] = []
    @Published var assistDraftPayload: AssistArchivePayload?
    @Published var assistDraftErrorMessage: String?
    @Published var isAssistGenerating: Bool = false
    @Published var isAssistDraftVisible: Bool = false
    @Published var assistThreads: [AssistThreadSummary] = []
    @Published var activeAssistThreadID: UUID?
    @Published var assistSplitSuggestionMessage: String?
    var activeAssistThreadTitle: String {
        guard let threadID = activeAssistThreadID else { return "新窗口" }
        return assistThreads.first(where: { $0.id == threadID })?.title ?? "窗口"
    }
    @Published var isRecording: Bool = false
    @Published var recordingStartedAt: Date?
    @Published var recordingLevel: Double = 0
    @Published var isMicPermissionAlertPresented: Bool = false
    @Published var micPermissionMessage: String = "请在系统设置中开启麦克风权限后再试。"
    @Published var isSpeechPermissionAlertPresented: Bool = false
    @Published var speechPermissionMessage: String = "请在系统设置中开启语音识别权限后再试。"
    @Published var recordingNoticeMessage: String?
    @Published var isAutoSplitInProgress: Bool = false
    @Published var autoSplitCompletedCount: Int = 0
    @Published var autoSplitTotalCount: Int = 0

    private let context: NSManagedObjectContext
    private let aiService: AIService
    private let calendar = Calendar.current
    private let voiceRecorder = VoiceRecorderController()
    private var currentRecordingURL: URL?
    private var recordingAutoStopTask: Task<Void, Never>?
    private var recordingWarningTask: Task<Void, Never>?
    private var recordingNoticeTask: Task<Void, Never>?
    private var recordingLevelTask: Task<Void, Never>?
    private var notificationObservers: [NSObjectProtocol] = []
    private var didActivateObservers: Bool = false
    private var transcriptionTasks: [UUID: Task<Void, Never>] = [:]
    private var assistGenerationTask: Task<Void, Never>?
    private let assistThreadMetaType = "assist_thread_meta"
    private let assistThreadMessageType = "assist_thread_message"
    private let captureRevisionType = "capture_revision"
    private let atomizationPayloadArtifactType = "atomization_payload"
    private let transcriptionPollIntervalNs: UInt64 = 5_000_000_000
    private let transcriptionRetryBaseDelayNs: UInt64 = 2_000_000_000
    private let transcriptionRetryMaxDelayNs: UInt64 = 30_000_000_000
    private let transcriptionMaxRetryAttempts: Int = 5
    private let maxRecordingDurationNs: UInt64 = 5 * 60 * 1_000_000_000
    private let recordingWarningLeadNs: UInt64 = 10 * 1_000_000_000
    private let transcriptionTimeoutSeconds: TimeInterval = 30
    private let transcriptionService: VoiceTranscribing
    private let transcriptionDebugStore = TranscriptionDebugStore.shared
    private let networkMonitor = NetworkMonitor.shared
    private var atomStore: AtomTagStore { AtomTagStore(context: context) }
    private var atomizationCoordinator: AtomizationCoordinator {
        AtomizationCoordinator(context: context, aiService: aiService)
    }
    private var networkListenerID: UUID?
    private var autoSplitTask: Task<Void, Never>?
    private var manualAtomizationTasks: [UUID: Task<Void, Never>] = [:]
    private var cleanTasks: [UUID: Task<Void, Never>] = [:]

    init(
        context: NSManagedObjectContext,
        aiService: AIService,
        transcriptionService: VoiceTranscribing? = nil
    ) {
        self.context = context
        self.aiService = aiService
        self.transcriptionService = transcriptionService ?? HybridVoiceTranscriptionService(aiService: aiService)
    }

    func activateIfNeeded() {
        guard !didActivateObservers else { return }
        registerRecordingObservers()
        registerDebugObservers()
        registerNetworkObserver()
        didActivateObservers = true
        schedulePendingAtomizationIfPossible()
    }

    private func registerNetworkObserver() {
        guard networkListenerID == nil else { return }
        networkListenerID = networkMonitor.addListener { [weak self] isConnected in
            guard let self else { return }
            if isConnected {
                self.schedulePendingAtomizationIfPossible()
            }
        }
    }

    private func schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [UUID] = []) {
        guard networkMonitor.isConnected else { return }
        guard autoSplitTask == nil else { return }

        let pendingEntities = fetchPendingSplitEntities(prioritizedCaptureIDs: prioritizedCaptureIDs)
        guard !pendingEntities.isEmpty else { return }

        autoSplitTask = Task { [weak self] in
            guard let self else { return }
            self.isAutoSplitInProgress = true
            self.autoSplitCompletedCount = 0
            self.autoSplitTotalCount = pendingEntities.count

            for entity in pendingEntities {
                if Task.isCancelled { break }
                await self.performAtomization(for: entity)
                self.autoSplitCompletedCount += 1
                self.loadCaptures()
            }

            self.isAutoSplitInProgress = false
            self.autoSplitCompletedCount = 0
            self.autoSplitTotalCount = 0
            self.autoSplitTask = nil
        }
    }

    private func fetchPendingSplitEntities(prioritizedCaptureIDs: [UUID]) -> [CaptureEntity] {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let entities = (try? context.fetch(request)) ?? []
        let pending = entities.filter(\.shouldAutoAtomizeForFormalRecord)

        var didPromoteState = false
        for entity in pending where entity.resolvedReviewProcessingState == .cleanReady {
            entity.processingState = CaptureProcessingState.pendingSplit.rawValue
            entity.atomizationError = nil
            didPromoteState = true
        }
        if didPromoteState {
            saveContext()
        }

        guard !prioritizedCaptureIDs.isEmpty else { return pending }

        let prioritized = pending.filter { prioritizedCaptureIDs.contains($0.id) }
        let remaining = pending.filter { !prioritizedCaptureIDs.contains($0.id) }
        return prioritized + remaining
    }

    private func performAtomization(for entity: CaptureEntity) async {
        guard let cleanText = entity.cleanText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !cleanText.isEmpty else { return }

        entity.processingState = CaptureProcessingState.splitting.rawValue
        entity.atomizationError = nil
        saveContext()
        postCaptureStateChanged(captureID: entity.id, atomizationStatusMessage: "已发送拆分请求…")

        do {
            try await atomizationCoordinator.atomizeCaptureIfNeeded(
                captureID: entity.id,
                cleanText: cleanText,
                progress: { [weak self] message in
                    self?.postCaptureStateChanged(captureID: entity.id, atomizationStatusMessage: message)
                }
            )
            entity.atomizationError = nil
            saveContext()
            postCaptureStateChanged(captureID: entity.id)
        } catch {
            let nextState: CaptureProcessingState = shouldDeferAtomization(for: error) ? .pendingSplit : .splitFailed
            entity.processingState = nextState.rawValue
            entity.atomizationError = atomizationFailureReason(for: error, deferred: nextState == .pendingSplit)
            saveContext()
            postCaptureStateChanged(captureID: entity.id)
            LogStore.shared.log("Atomization failed for \(entity.id): \(error.localizedDescription)", category: .network)
        }
    }

    private func postCaptureStateChanged(captureID: UUID, atomizationStatusMessage: String? = nil) {
        var userInfo: [String: Any] = ["captureID": captureID]
        if let atomizationStatusMessage {
            userInfo["atomizationStatusMessage"] = atomizationStatusMessage
        }
        NotificationCenter.default.post(
            name: .captureProcessingStateChanged,
            object: nil,
            userInfo: userInfo
        )
    }

    private func shouldDeferAtomization(for error: Error) -> Bool {
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .httpStatus(let code):
                if code == 402 {
                    return false
                }
                return [408, 429, 500, 502, 503, 504].contains(code)
            case .emptyResponse, .invalidResponse:
                return false
            case .missingAPIKey, .unsupported:
                return false
            }
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return [
                NSURLErrorNotConnectedToInternet,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorTimedOut,
                NSURLErrorCannotConnectToHost,
                NSURLErrorDNSLookupFailed
            ].contains(nsError.code)
        }
        return false
    }

    private func atomizationFailureReason(for error: Error, deferred: Bool) -> String {
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .httpStatus(let code):
                if code == 402 {
                    return "本月免费 AI 额度已用完，下月会自动恢复。记录功能仍可继续使用。"
                }
                if deferred {
                    switch code {
                    case 408:
                        return "AI 拆分请求超时，将自动重试。"
                    case 429:
                        return "AI 拆分服务限流中，将自动重试。"
                    case 500, 502, 503, 504:
                        return "AI 拆分服务暂时不可用，将自动重试。"
                    default:
                        return "AI 服务异常 HTTP\(code)。"
                    }
                }
                return "AI 服务异常 HTTP\(code)。"
            case .invalidResponse:
                return "AI 拆分返回格式异常，请重新拆分。"
            case .emptyResponse:
                return "AI 拆分结果为空，请重新拆分。"
            case .missingAPIKey:
                return "AI 服务暂时不可用，请稍后再试。"
            case .unsupported:
                return "当前环境不支持 AI 拆分。"
            }
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return "当前网络不可用，恢复后会自动拆分。"
            case NSURLErrorTimedOut:
                return "拆分请求超时，将自动重试。"
            case NSURLErrorCannotConnectToHost, NSURLErrorDNSLookupFailed:
                return "无法连接拆分服务，将自动重试。"
            default:
                break
            }
        }

        return "拆分失败：\(error.localizedDescription)"
    }

    func loadCaptures() {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "isHiddenFromFeed == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            let artifactMap = loadArtifacts(for: results.map { $0.id })
            let revisionCountMap = loadRevisionCounts(for: results.map { $0.id })

            captures = results.map { entity in
                makeCaptureItem(
                    from: entity,
                    assistRecord: artifactMap[entity.id],
                    revisionCount: revisionCountMap[entity.id] ?? 0
                )
            }
            restorePendingTranscriptions(from: results)
            schedulePendingAtomizationIfPossible()
        } catch {
            captures = []
        }
    }

    func addCaptureFromInput() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch inputMode {
        case .log:
            inputText = ""
            createLogCapture(from: trimmed)
        case .assist:
            guard !isAssistGenerating else { return }
            inputText = ""
            isAssistDraftVisible = false
            startAssistSessionTurn(questionText: trimmed)
        }
    }

    func makeDetailItem(for id: UUID) -> CaptureItem? {
        captures.first { $0.id == id }
    }

    func ensureActiveAssistThread() {
        loadAssistThreads()
        if activeAssistThreadID == nil {
            createNewAssistThread()
        } else if let threadID = activeAssistThreadID {
            loadAssistSession(threadID: threadID)
        }
    }

    func createNewAssistThread() {
        let now = Date()
        let threadID = UUID()
        let title = "窗口 \(formattedThreadTime(now))"
        let summary = AssistThreadSummary(
            id: threadID,
            title: title,
            status: .active,
            linkedCaptureIDs: [],
            createdAt: now,
            updatedAt: now
        )
        saveAssistThread(summary)
        assistThreads.insert(summary, at: 0)
        activeAssistThreadID = threadID
        assistSessionMessages = []
        assistDraftPayload = nil
        assistDraftErrorMessage = nil
        isAssistDraftVisible = false
        assistSplitSuggestionMessage = nil
        if inputMode == .assist {
            inputText = ""
        }
    }

    func openAssistThread(_ threadID: UUID) {
        activeAssistThreadID = threadID
        assistSplitSuggestionMessage = nil
        loadAssistSession(threadID: threadID)
    }

    func requestAssistThreadSplit() {
        closeActiveThreadIfNeeded()
        createNewAssistThread()
    }

    func dismissAssistSplitSuggestion() {
        assistSplitSuggestionMessage = nil
    }

    func showAssistDraftCard() {
        guard !isAssistGenerating else { return }
        guard activeAssistThreadID != nil else {
            assistDraftErrorMessage = "当前没有可整理的会话。"
            return
        }
        guard !assistSessionMessages.isEmpty else {
            assistDraftErrorMessage = "请先完成一轮助手回复，再整理为记录。"
            return
        }
        if assistDraftPayload != nil {
            isAssistDraftVisible = true
            return
        }
        generateAssistDraftForActiveThread(autoOpen: true)
    }

    func hideAssistDraftCard() {
        isAssistDraftVisible = false
    }

    func regenerateAssistDraft() {
        guard !isAssistGenerating else { return }
        generateAssistDraftForActiveThread(autoOpen: true)
    }

    func assistDraftEditorBodyText() -> String {
        guard let payload = assistDraftPayload else { return "" }
        return assistDraftBodyText(from: payload)
    }

    func saveAssistDraftEdits(title: String, body: String) {
        guard let payload = assistDraftPayload else { return }
        assistDraftPayload = editedAssistDraftPayload(from: payload, title: title, body: body)
    }

    func commitAssistDraftToRecord(title: String, body: String) {
        guard let payload = assistDraftPayload else { return }
        assistDraftPayload = editedAssistDraftPayload(from: payload, title: title, body: body)
        commitAssistDraftToRecord()
    }

    func commitAssistDraftToRecord() {
        guard let payload = assistDraftPayload else { return }
        guard let threadID = activeAssistThreadID else {
            createNewAssistThread()
            return
        }

        let text = assistRecordText(from: payload)
        let linkedCaptureIDs = currentThreadLinkedCaptureIDs(threadID: threadID)
        if let latestCaptureID = linkedCaptureIDs.last {
            applyRevision(to: latestCaptureID, newText: text, threadID: threadID)
        } else {
            let newCaptureID = createLogCapture(from: text, sourceThreadID: threadID)
            updateThreadLinkedCaptures(threadID: threadID, linkedCaptureIDs: [newCaptureID])
        }

        closeThread(threadID: threadID)
        createNewAssistThread()
        showRecordingNotice("已写入记录，接下来会继续整理拆分和标签")
    }

    func resetAssistSession() {
        if let threadID = activeAssistThreadID {
            closeThread(threadID: threadID)
        }
        assistGenerationTask?.cancel()
        assistGenerationTask = nil
        isAssistGenerating = false
        assistDraftPayload = nil
        assistDraftErrorMessage = nil
        isAssistDraftVisible = false
        assistSessionMessages = []
        assistSplitSuggestionMessage = nil
        createNewAssistThread()
    }

    func saveAssistArchive(captureID: UUID) {
        guard let artifact = fetchArtifact(captureID: captureID),
              let payload = AssistArchivePayload.decode(from: artifact.contentJSON) else { return }

        let currentStatus = AssistArchiveStatus(rawValue: artifact.status) ?? .draft
        guard currentStatus == .draft else { return }

        let atomIDs = atomStore.createAtoms(fromArchive: payload, captureID: captureID)
        if !atomIDs.isEmpty {
            atomStore.assignTagSuggestions(payload.card.tagSuggestions, to: atomIDs)
            atomStore.updateCaptureStats(captureID: captureID, atomsCount: atomIDs.count, processingState: .tagsSuggested)
        }

        artifact.status = AssistArchiveStatus.saved.rawValue
        artifact.updatedAt = Date()
        if let capture = fetchCaptureEntity(captureID: captureID) {
            _ = ReviewMaterialRepairService(context: context).backfillLegacyAssistArchivePayloads(for: [capture])
        }
        saveContext()
        loadCaptures()
    }

    func startRecording() {
        guard !isRecording else { return }

        Task { @MainActor in
            let granted = await voiceRecorder.requestPermission()
            guard granted else {
                micPermissionMessage = "麦克风权限已关闭。请在“设置 > Life Narattor > 麦克风”中开启后再试。"
                isMicPermissionAlertPresented = true
                return
            }

            if !FeatureFlags.shared.isAITranscriptionPreferred {
                let speechAuthorized = await SpeechAuthorizationManager.requestAuthorization()
                guard speechAuthorized else {
                    speechPermissionMessage = "语音识别权限已关闭。请在“设置 > Life Narattor > 语音识别”中开启后再试。"
                    isSpeechPermissionAlertPresented = true
                    return
                }
            }

            do {
                currentRecordingURL = try voiceRecorder.startRecording()
                isRecording = true
                recordingStartedAt = Date()
                scheduleRecordingAutoStop()
                scheduleRecordingPreStopWarning()
                startRecordingLevelMonitoring()
            } catch {
                LogStore.shared.log("Recording start failed: \(error.localizedDescription)", category: .jobs)
            }
        }
    }

    func cancelRecording() {
        recordingAutoStopTask?.cancel()
        recordingAutoStopTask = nil
        recordingWarningTask?.cancel()
        recordingWarningTask = nil
        recordingLevelTask?.cancel()
        recordingLevelTask = nil
        voiceRecorder.cancelRecording()
        currentRecordingURL = nil
        isRecording = false
        recordingStartedAt = nil
        recordingLevel = 0
    }

    func stopRecording() {
        stopRecording(rawText: "语音记录", noticeMessage: nil)
    }

    func dismissRecordingNotice() {
        recordingNoticeTask?.cancel()
        recordingNoticeMessage = nil
    }

    private func stopRecording(rawText: String, noticeMessage: String?) {
        guard isRecording else { return }
        recordingAutoStopTask?.cancel()
        recordingAutoStopTask = nil
        recordingWarningTask?.cancel()
        recordingWarningTask = nil
        recordingLevelTask?.cancel()
        recordingLevelTask = nil
        guard let audioURL = voiceRecorder.stopRecording() ?? currentRecordingURL else {
            isRecording = false
            recordingStartedAt = nil
            recordingLevel = 0
            return
        }
        isRecording = false
        recordingStartedAt = nil
        recordingLevel = 0
        currentRecordingURL = nil

        let createdAt = Date()
        let part = dayPart(for: createdAt, fallback: nil)
        if inputMode == .assist, activeAssistThreadID == nil {
            createNewAssistThread()
        }
        let draft = VoiceCaptureDraft(
            id: UUID(),
            createdAt: createdAt,
            rawText: rawText,
            dayPart: part,
            mode: inputMode,
            audioPath: audioURL.path,
            sourceThreadID: inputMode == .assist ? activeAssistThreadID : nil
        )

        guard persistVoiceCapture(draft) else {
            showRecordingNotice("录音保存失败，请重试")
            return
        }

        loadCaptures()
        enqueueTranscription(captureID: draft.id, shouldResetToPending: false)
        if let noticeMessage {
            showRecordingNotice(noticeMessage)
        }
    }

    func dismissMicPermissionAlert() {
        isMicPermissionAlertPresented = false
    }

    func dismissSpeechPermissionAlert() {
        isSpeechPermissionAlertPresented = false
    }

    func retryTranscription(captureID: UUID) {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }

        entity.transcriptionStatus = TranscriptionStatus.pending.rawValue
        entity.transcriptionError = nil
        entity.transcriptText = nil
        entity.cleanText = nil
        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.atomizationError = nil
        entity.atomsCount = 0
        atomStore.clearAtomsForCapture(captureID: captureID)
        clearAtomizationPayload(captureID: captureID)
        saveContext()
        enqueueTranscription(captureID: captureID, shouldResetToPending: true)
        loadCaptures()
        postCaptureStateChanged(captureID: captureID)
    }

    func retryAtomization(captureID: UUID) {
        guard let entity = fetchCaptureEntity(captureID: captureID),
              let cleanText = entity.cleanText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !cleanText.isEmpty else { return }

        manualAtomizationTasks[captureID]?.cancel()
        clearAtomizationPayload(captureID: captureID)
        entity.processingState = networkMonitor.isConnected ? CaptureProcessingState.splitting.rawValue : CaptureProcessingState.pendingSplit.rawValue
        entity.atomizationError = networkMonitor.isConnected ? nil : "当前网络不可用，恢复后会自动拆分。"
        saveContext()
        loadCaptures()
        postCaptureStateChanged(
            captureID: captureID,
            atomizationStatusMessage: networkMonitor.isConnected ? "已发送拆分请求…" : nil
        )

        guard networkMonitor.isConnected else {
            schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [captureID])
            return
        }

        manualAtomizationTasks[captureID] = Task { [weak self] in
            guard let self else { return }
            await self.performAtomization(for: entity)
            self.manualAtomizationTasks[captureID] = nil
            self.loadCaptures()
        }
    }

    func retryClean(captureID: UUID, forceAI: Bool = true) {
        guard let entity = fetchCaptureEntity(captureID: captureID) else { return }
        let sourceText = (entity.transcriptText ?? entity.rawText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sourceText.isEmpty else { return }

        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.atomizationError = nil
        entity.atomsCount = 0
        atomStore.clearAtomsForCapture(captureID: captureID)
        clearAtomizationPayload(captureID: captureID)
        saveContext()
        loadCaptures()
        postCaptureStateChanged(captureID: captureID)
        scheduleClean(captureID: captureID, sourceText: sourceText, forceAI: forceAI)
    }

    func updateAssistArchive(captureID: UUID, payload: AssistArchivePayload) {
        guard let artifact = fetchArtifact(captureID: captureID) else { return }
        artifact.title = payload.card.title
        artifact.contentJSON = payload.encodedJSON() ?? artifact.contentJSON
        artifact.updatedAt = Date()
        saveContext()
        loadCaptures()
    }

    func endAssistArchive(captureID: UUID) {
        guard let artifact = fetchArtifact(captureID: captureID) else { return }
        artifact.status = AssistArchiveStatus.ended.rawValue
        artifact.updatedAt = Date()
        saveContext()
        loadCaptures()
    }

    @discardableResult
    private func createLogCapture(from text: String, sourceThreadID: UUID? = nil) -> UUID {
        let entity = CaptureEntity(context: context)
        let createdAt = Date()
        let part = dayPart(for: createdAt, fallback: nil)
        let captureID = UUID()
        let cleanResult = CleanDefiller.clean(text)

        entity.id = captureID
        entity.createdAt = createdAt
        entity.isHiddenFromFeed = false
        entity.rawText = text
        entity.cleanText = cleanResult.cleanText
        entity.dayPart = part.rawValue
        entity.mode = CaptureInputMode.log.rawValue
        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.atomsCount = 0
        entity.atomizationError = nil
        entity.inputType = CaptureInputType.text.rawValue
        entity.sourceThreadID = sourceThreadID
        clearAtomizationPayload(captureID: captureID)

        saveContext()
        loadCaptures()

        Task {
            await updateQuickAck(for: entity)
        }
        scheduleClean(captureID: captureID, sourceText: text, forceAI: false)
        return captureID
    }

    private func startAssistSessionTurn(questionText: String) {
        if activeAssistThreadID == nil {
            createNewAssistThread()
        }
        guard let threadID = activeAssistThreadID else { return }
        assistDraftErrorMessage = nil
        assistDraftPayload = nil
        isAssistDraftVisible = false
        let userMessage = AssistSessionMessage(role: .user, text: questionText, createdAt: Date())
        assistSessionMessages.append(userMessage)
        saveAssistThreadMessage(threadID: threadID, message: userMessage)
        isAssistGenerating = true

        if shouldSuggestThreadSplit(for: questionText, threadID: threadID) {
            assistSplitSuggestionMessage = "检测到你可能在聊新主题，要不要拆成新窗口？"
        } else {
            assistSplitSuggestionMessage = nil
        }

        let threadMessages = loadAssistThreadMessages(threadID: threadID)
        let contextText = assistContextText(from: threadMessages)
        let contextCapture = makeAssistSessionCapture(from: contextText)
        assistGenerationTask?.cancel()
        assistGenerationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let reply = try await self.aiService.chatReply(
                    for: contextCapture,
                    questionText: questionText
                )
                guard !Task.isCancelled else { return }
                let replyThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                let normalizedReply = self.normalizeAssistReply(reply, questionText: questionText, messages: replyThreadMessages)
                let assistantMessage = AssistSessionMessage(role: .assistant, text: normalizedReply, createdAt: Date())
                self.saveAssistThreadMessage(threadID: threadID, message: assistantMessage)
                self.touchThread(threadID: threadID)
                let refreshedThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                if self.activeAssistThreadID == threadID {
                    self.assistDraftErrorMessage = nil
                    self.assistSessionMessages = refreshedThreadMessages
                }
            } catch {
                guard !Task.isCancelled else { return }
                let primaryError = error

                do {
                    // Fallback to lighter prompt path so user still gets an AI response.
                    let quick = try await self.aiService.quickAck(for: contextCapture)
                    guard !Task.isCancelled else { return }

                    let replyText = quick.ackDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? quick.ackTitle
                        : quick.ackDetail
                    let replyThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                    let effectiveQuestion = self.effectiveAssistQuestionText(for: questionText, messages: replyThreadMessages)
                    let fallbackReply = self.normalizeAssistReply(replyText, questionText: effectiveQuestion, messages: replyThreadMessages)
                    let assistantMessage = AssistSessionMessage(
                        role: .assistant,
                        text: fallbackReply,
                        createdAt: Date()
                    )
                    self.saveAssistThreadMessage(threadID: threadID, message: assistantMessage)
                    self.touchThread(threadID: threadID)
                    let refreshedThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                    if self.activeAssistThreadID == threadID {
                        self.assistDraftPayload = nil
                        self.isAssistDraftVisible = false
                        self.assistDraftErrorMessage = nil
                        self.assistSessionMessages = refreshedThreadMessages
                    }
                    LogStore.shared.log(
                        "Assist fallback to quickAck succeeded after assistArchive failed: \(primaryError.localizedDescription)",
                        category: .ai
                    )
                } catch {
                    guard !Task.isCancelled else { return }
                    let assistantMessage = AssistSessionMessage(
                        role: .assistant,
                        text: "我这次没有收到可用的 AI 回复，请再发一次。",
                        createdAt: Date()
                    )
                    self.saveAssistThreadMessage(threadID: threadID, message: assistantMessage)
                    let refreshedThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                    if self.activeAssistThreadID == threadID {
                        self.assistDraftPayload = nil
                        self.assistDraftErrorMessage = "AI 回复失败，请重试。"
                        self.assistSessionMessages = refreshedThreadMessages
                    }
                    LogStore.shared.log(
                        "Assist session turn failed on both paths: primary=\(primaryError.localizedDescription), fallback=\(error.localizedDescription)",
                        category: .ai
                    )
                }
            }

            guard !Task.isCancelled else { return }
            self.isAssistGenerating = false
            self.assistGenerationTask = nil
        }
    }

    private func scheduleClean(captureID: UUID, sourceText: String, forceAI: Bool) {
        cleanTasks[captureID]?.cancel()
        cleanTasks[captureID] = Task { [weak self] in
            guard let self else { return }
            let cleanResult = await self.resolveCleanResult(for: sourceText, forceAI: forceAI)
            guard !Task.isCancelled else { return }
            guard let entity = self.fetchCaptureEntity(captureID: captureID) else { return }

            entity.cleanText = cleanResult.cleanText
            entity.processingState = CaptureProcessingState.pendingSplit.rawValue
            entity.atomizationError = nil
            self.saveContext()
            self.loadCaptures()
            self.postCaptureStateChanged(captureID: captureID)
            self.schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [captureID])
            self.cleanTasks[captureID] = nil
        }
    }

    private func resolveCleanResult(for sourceText: String, forceAI: Bool) async -> CleanDefillerResult {
        let ruleResult = CleanDefiller.clean(sourceText)
        let complexity = CleanDefiller.analyzeComplexity(originalText: sourceText, cleanedText: ruleResult.cleanText)
        let shouldUseAI = forceAI || complexity.shouldUseAI
        guard shouldUseAI else {
            return ruleResult
        }

        do {
            return try await aiService.cleanTranscript(text: sourceText, forceAI: forceAI)
        } catch {
            LogStore.shared.log(
                "AI clean fallback to rules: \(error.localizedDescription) reasons=\(complexity.reasons.joined(separator: ","))",
                category: .ai
            )
            return ruleResult
        }
    }

    private func generateAssistDraftForActiveThread(autoOpen: Bool) {
        guard let threadID = activeAssistThreadID else { return }
        let threadMessages = loadAssistThreadMessages(threadID: threadID)
        let archiveQuestion = archiveQuestionText(from: threadMessages)
        guard !archiveQuestion.isEmpty else {
            assistDraftErrorMessage = "当前没有可整理的用户问题。"
            return
        }

        assistDraftErrorMessage = nil
        isAssistGenerating = true
        assistGenerationTask?.cancel()
        let contextText = assistContextText(from: threadMessages, maxMessages: nil)
        let contextCapture = makeAssistSessionCapture(from: contextText)

        assistGenerationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let payload = try await self.aiService.assistArchive(
                    for: contextCapture,
                    questionText: archiveQuestion
                )
                guard !Task.isCancelled else { return }
                let replyThreadMessages = self.loadAssistThreadMessages(threadID: threadID)
                let enrichedPayload = self.enrichAssistPayloadIfNeeded(
                    payload,
                    questionText: archiveQuestion,
                    messages: replyThreadMessages
                )
                if self.activeAssistThreadID == threadID {
                    self.assistDraftPayload = enrichedPayload
                    self.isAssistDraftVisible = autoOpen
                    self.assistDraftErrorMessage = nil
                }
            } catch {
                guard !Task.isCancelled else { return }
                if self.activeAssistThreadID == threadID {
                    self.assistDraftPayload = nil
                    self.isAssistDraftVisible = false
                    self.assistDraftErrorMessage = self.assistDraftFailureReason(for: error)
                }
                LogStore.shared.log("Assist draft generation failed: \(error.localizedDescription)", category: .ai)
            }

            guard !Task.isCancelled else { return }
            self.isAssistGenerating = false
            self.assistGenerationTask = nil
        }
    }

    private func archiveQuestionText(from messages: [AssistSessionMessage]) -> String {
        let userMessages = messages
            .filter { $0.role == .user }
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !userMessages.isEmpty else { return "" }

        let combined = userMessages.enumerated()
            .map { index, text in "\(index + 1). \(text)" }
            .joined(separator: "\n")

        return """
        请基于整个当前会话整理成一条记录，覆盖会话里提到的所有问题、分析和后续动作，不要只总结最后一轮。
        同时按主题把内容分化成 1-4 条独立记录单元，每条都应当是完整意思，不要拆成句子碎片。
        当前窗口中的用户输入如下：
        \(combined)
        """
    }

    private func assistContextText(from messages: [AssistSessionMessage], maxMessages: Int? = 8) -> String {
        let sourceMessages: ArraySlice<AssistSessionMessage>
        if let maxMessages {
            sourceMessages = messages.suffix(maxMessages)
        } else {
            sourceMessages = ArraySlice(messages)
        }

        return sourceMessages
            .map { message in
                let prefix = message.role == .user ? "用户：" : "助手："
                return "\(prefix)\(message.text)"
            }
            .joined(separator: "\n")
    }

    private func makeAssistSessionCapture(from contextText: String) -> CaptureItem {
        let createdAt = Date()
        let safeText = contextText.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = safeText.isEmpty ? "助手会话上下文" : safeText
        return CaptureItem(
            id: UUID(),
            createdAt: createdAt,
            rawText: source,
            cleanText: source,
            ackTitle: nil,
            ackDetail: nil,
            dayPart: dayPart(for: createdAt, fallback: nil),
            mode: .assist,
            assistRecord: nil,
            atomsCount: 0,
            processingState: .cleanReady,
            inputType: .text,
            audioPath: nil,
            transcriptText: nil,
            transcriptionStatus: nil,
            transcriptionErrorReason: nil,
            isTranscriptionActive: false
        )
    }

    private func assistRecordText(from payload: AssistArchivePayload) -> String {
        var lines: [String] = []
        if let latestQuestion = assistSessionMessages.last(where: { $0.role == .user })?.text,
           !latestQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("助手会话：\(latestQuestion)")
        }
        lines.append(payload.card.title)
        if !payload.card.context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append(payload.card.context)
        }
        if !payload.card.effectiveRecordUnits.isEmpty {
            lines.append("分化记录：")
            for unit in payload.card.effectiveRecordUnits {
                lines.append("- \(unit.title)：\(unit.summary)")
            }
        } else if !payload.card.keyPoints.isEmpty {
            lines.append("要点：\(payload.card.keyPoints.joined(separator: "；"))")
        }
        if !payload.card.nextSteps.isEmpty {
            lines.append("下一步：\(payload.card.nextSteps.joined(separator: "；"))")
        }
        let text = lines.joined(separator: "\n")
        return text.isEmpty ? payload.reply : text
    }

    private func assistDraftBodyText(from payload: AssistArchivePayload) -> String {
        var sections: [String] = []

        let context = payload.card.context.trimmingCharacters(in: .whitespacesAndNewlines)
        if !context.isEmpty {
            sections.append(context)
        }

        let recordUnits = payload.card.effectiveRecordUnits
        if !recordUnits.isEmpty {
            for unit in recordUnits {
                var lines: [String] = []
                if !unit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    lines.append(unit.title)
                }
                if !unit.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    lines.append(unit.summary)
                }
                if !unit.keyPoints.isEmpty {
                    lines.append("要点：\(unit.keyPoints.joined(separator: "；"))")
                }
                if !unit.nextSteps.isEmpty {
                    lines.append("下一步：\(unit.nextSteps.joined(separator: "；"))")
                }
                let block = lines
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n")
                if !block.isEmpty {
                    sections.append(block)
                }
            }
        } else {
            if !payload.card.keyPoints.isEmpty {
                sections.append("要点：\(payload.card.keyPoints.joined(separator: "；"))")
            }
            if !payload.card.nextSteps.isEmpty {
                sections.append("下一步：\(payload.card.nextSteps.joined(separator: "；"))")
            }
        }

        return sections.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func editedAssistDraftPayload(from payload: AssistArchivePayload, title: String, body: String) -> AssistArchivePayload {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        return AssistArchivePayload(
            reply: payload.reply,
            card: AssistArchiveCard(
                title: cleanedTitle.isEmpty ? payload.card.title : cleanedTitle,
                context: cleanedBody,
                keyPoints: [],
                nextSteps: [],
                recordUnits: [],
                tagSuggestions: payload.card.tagSuggestions,
                confidence: payload.card.confidence
            ),
            turnPolicy: payload.turnPolicy
        )
    }

    private func enrichAssistPayloadIfNeeded(
        _ payload: AssistArchivePayload,
        questionText: String,
        messages: [AssistSessionMessage]
    ) -> AssistArchivePayload {
        let effectiveQuestion = effectiveAssistQuestionText(for: questionText, messages: messages)
        let normalizedReply = normalizeAssistReply(payload.reply, questionText: effectiveQuestion, messages: messages)
        let normalizedKeyPoints = normalizeAssistKeyPoints(payload.card.keyPoints)
        let normalizedNextSteps = normalizeAssistNextSteps(payload.card.nextSteps)
        let normalizedTitle = normalizeAssistDraftTitle(payload.card.title, questionText: effectiveQuestion)
        let normalizedContext = normalizeAssistDraftNarration(payload.card.context)
        let normalizedRecordUnits = payload.card.recordUnits.compactMap { normalizeAssistRecordUnit($0) }

        return AssistArchivePayload(
            reply: normalizedReply,
            card: AssistArchiveCard(
                title: normalizedTitle,
                context: normalizedContext,
                keyPoints: normalizedKeyPoints,
                nextSteps: normalizedNextSteps,
                recordUnits: normalizedRecordUnits,
                tagSuggestions: payload.card.tagSuggestions,
                confidence: payload.card.confidence
            ),
            turnPolicy: payload.turnPolicy
        )
    }

    private func normalizeAssistReply(_ reply: String, questionText: String, messages: [AssistSessionMessage]) -> String {
        let effectiveQuestion = effectiveAssistQuestionText(for: questionText, messages: messages)
        let trimmed = reply.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "我先没接住这句，你换个说法再发一次。"
        }

        var normalized = stripMetaFiller(trimmed, questionText: effectiveQuestion)
        normalized = stripRepeatedWhitespace(normalized)
        return normalized.isEmpty ? "我先没接住这句，你换个说法再发一次。" : normalized
    }

    private func normalizeAssistDraftTitle(_ title: String, questionText: String) -> String {
        var normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            return draftTitle(for: questionText)
        }

        normalized = normalized
            .replacingOccurrences(of: "总结", with: "整理")
            .replacingOccurrences(of: "摘要", with: "整理")
            .replacingOccurrences(of: "纪要", with: "记录")
            .replacingOccurrences(of: "用户咨询", with: "")
            .replacingOccurrences(of: "助手对话", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "：:- ").union(.whitespacesAndNewlines))

        if normalized.isEmpty {
            return draftTitle(for: questionText)
        }
        return normalized
    }

    private func normalizeAssistDraftNarration(_ text: String) -> String {
        var normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return normalized }

        let replacements: [(String, String)] = [
            ("用户咨询", "这次整理围绕"),
            ("用户询问", "这次整理围绕"),
            ("用户讨论", "这次整理围绕"),
            ("用户提到", "这次整理提到"),
            ("用户想知道", "这次整理围绕"),
            ("用户考虑", "这次整理围绕"),
            ("助手建议", "这里也提到"),
            ("助手解释", "这里也梳理了"),
            ("助手指出", "这里也提到"),
            ("助手提醒", "这里也提醒"),
            ("助手认为", "这里更偏向"),
            ("本次对话中", ""),
            ("对话中", ""),
            ("用户", ""),
            ("助手", "")
        ]

        replacements.forEach { source, target in
            normalized = normalized.replacingOccurrences(of: source, with: target)
        }

        normalized = normalized
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "。。", with: "。")
            .replacingOccurrences(of: "，，", with: "，")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return normalized
    }

    private func normalizeAssistRecordUnit(_ unit: AssistRecordUnit) -> AssistRecordUnit? {
        let title = normalizeAssistDraftTitle(unit.title, questionText: unit.summary)
        let summary = normalizeAssistDraftNarration(unit.summary)
        let keyPoints = unit.keyPoints.map(normalizeAssistDraftNarration)
        let nextSteps = unit.nextSteps.map(normalizeAssistDraftNarration)

        return AssistRecordUnit(
            title: title,
            summary: summary,
            keyPoints: keyPoints,
            nextSteps: nextSteps
        ).normalizedOrNil
    }

    private func draftTitle(for questionText: String) -> String {
        let words = extractEnglishWords(from: questionText)
        if isPronunciationTopic(questionText: questionText, words: words) {
            if words.count == 1 {
                return "发音练习：\(words[0])"
            }
            guard words.count >= 2 else { return "发音练习记录" }
            return "专项练习：\(words[0]) / \(words[1])"
        }
        let compact = questionText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let short = String(compact.prefix(14))
        return short.isEmpty ? "问题分析记录" : "问题分析：\(short)"
    }

    private func isPronunciationTopic(questionText: String, words: [String]) -> Bool {
        let markers = ["发音", "读音", "口型", "音标", "跟读", "单词", "英语", "英文", "讲", "读"]
        let confusionCues = ["混", "分不清", "搞混", "说错", "读错", "讲错", "总把", "老是把", "容易混", "咬嘴", "绕口", "嘴瓢", "说不清", "讲不清楚"]
        let containsMarker = markers.contains { questionText.contains($0) }
        let hasConfusionCue = confusionCues.contains { questionText.contains($0) }
        let hasEnglishWord = !words.isEmpty
        return (containsMarker || hasConfusionCue) && hasEnglishWord
    }

    private func hasImplicitHelpIntent(_ text: String) -> Bool {
        let cues = [
            "总是", "老是", "一直", "不会", "搞不懂", "分不清", "混", "卡住", "困难", "问题", "错误", "老出错", "总出错"
        ]
        return cues.contains { text.contains($0) }
    }

    

    private func effectiveAssistQuestionText(for text: String, messages: [AssistSessionMessage]) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isLikelyShortFollowUpAnswer(trimmed) else { return trimmed }
        guard let previousUser = previousUserMessage(beforeLatestUserText: trimmed, messages: messages) else { return trimmed }
        guard let previousAssistant = messages.last(where: { $0.role == .assistant })?.text else {
            return trimmed
        }
        guard previousAssistant.contains("？") || previousAssistant.contains("?") else { return trimmed }

        return "\(previousUser) 补充：\(trimmed)"
    }

    private func isLikelyShortFollowUpAnswer(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        if text.count <= 8 { return true }
        let shortCues = ["开头", "结尾", "前半段", "后半段", "第一个", "第二个", "前面", "后面", "是", "不是"]
        return shortCues.contains(where: { text == $0 })
    }

    private func previousUserMessage(beforeLatestUserText latest: String, messages: [AssistSessionMessage]) -> String? {
        let userMessages = messages.filter { $0.role == .user }
        guard userMessages.count >= 2 else { return nil }
        let previous = userMessages[userMessages.count - 2].text.trimmingCharacters(in: .whitespacesAndNewlines)
        return previous.isEmpty ? nil : previous
    }

    private func stripMetaFiller(_ reply: String, questionText: String) -> String {
        let fillers = [
            "我理解你这轮",
            "我先给你",
            "从你给的信息看",
            "我们一步一步来",
            "这个很正常，你抓得很准。",
            "很多人都会遇到",
            "你不是一个人",
            "不用太担心",
            "别给自己太大压力"
        ]
        var output = reply
        for filler in fillers {
            output = output.replacingOccurrences(of: filler, with: "")
        }
        if looksLikeParaphraseOnly(output, questionText: questionText) {
            return ""
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func stripRepeatedWhitespace(_ text: String) -> String {
        text
            .replacingOccurrences(of: "[\\t\\f\\r ]{2,}", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func limitReplyLength(_ text: String, maxChars: Int) -> String {
        guard text.count > maxChars else { return text }
        let clipped = String(text.prefix(maxChars))
        if let sentenceEnd = clipped.lastIndex(where: { "。！？.!?".contains($0) }) {
            return String(clipped[...sentenceEnd])
        }
        return clipped + "。"
    }

    private func looksLikeParaphraseOnly(_ reply: String, questionText: String) -> Bool {
        let compactReply = compactText(reply)
        let compactQuestion = compactText(questionText)
        guard !compactReply.isEmpty, !compactQuestion.isEmpty else { return false }

        let onlyRepeat = compactReply.contains(compactQuestion) || compactQuestion.contains(compactReply)
        let hasCause = ["因为", "通常", "常见", "原因", "多半", "可能", "区别", "重点", "卡在"].contains { reply.contains($0) }
        let hasAction = ["先", "试", "做", "练", "步骤", "下一步", "可以", "写下", "整理", "注意"].contains { reply.contains($0) }
        return onlyRepeat && !(hasCause || hasAction)
    }

    private func normalizeAssistKeyPoints(_ keyPoints: [String]) -> [String] {
        let cleaned = keyPoints
            .map { stripRepeatedWhitespace($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.isEmpty && !looksCoachyFragment($0) }

        return Array(cleaned.prefix(2))
    }

    private func normalizeAssistNextSteps(_ nextSteps: [String]) -> [String] {
        let cleaned = nextSteps
            .map { stripRepeatedWhitespace($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.isEmpty && !looksCoachyFragment($0) }

        return Array(cleaned.prefix(1))
    }

    private func looksCoachyFragment(_ text: String) -> Bool {
        let markers = [
            "一步一步",
            "陪你",
            "鼓励",
            "坚持",
            "完整计划",
            "系统方案",
            "详细方案",
            "复盘",
            "细化方案"
        ]
        return markers.contains { text.contains($0) }
    }

    private func wantsDetailedPlan(_ text: String) -> Bool {
        let cues = ["详细", "细一点", "展开", "完整", "步骤", "系统", "具体计划", "分步"]
        return cues.contains { text.contains($0) }
    }

    private func wantsWriteBack(_ text: String) -> Bool {
        let cues = ["记进去", "记一下", "记录一下", "记到记录", "整理成记录", "归档", "存一下"]
        return cues.contains { text.contains($0) }
    }

    private func compactText(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "，", with: "")
            .replacingOccurrences(of: "。", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
    }

    private func conversationBridgePrefix(for questionText: String, messages: [AssistSessionMessage]) -> String {
        let userMessages = messages.filter { $0.role == .user }
        guard userMessages.count >= 2 else { return "" }
        let previous = userMessages[userMessages.count - 2].text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !previous.isEmpty else { return "" }

        let overlap = lexicalOverlap(previous, questionText)
        guard overlap >= 0.12 else { return "" }

        let snippet = String(previous.prefix(14))
        return "接着你刚才提到的「\(snippet)」，"
    }

    private func ipaHint(for word: String) -> String {
        switch word.lowercased() {
        case "fan":
            return " /fæn/"
        case "fine":
            return " /faɪn/"
        case "crazy":
            return " /ˈkreɪzi/"
        default:
            return ""
        }
    }

    private func extractEnglishWords(from text: String) -> [String] {
        let pattern = #"[A-Za-z]{2,}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let source = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: source.length))
        var result: [String] = []
        for match in matches {
            let token = source.substring(with: match.range).lowercased()
            if !result.contains(token) {
                result.append(token)
            }
        }
        return result
    }

    private func loadAssistThreads() {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@", assistThreadMetaType)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let artifacts = (try? context.fetch(request)) ?? []
        let summaries = artifacts.compactMap { artifact -> AssistThreadSummary? in
            guard let payload = AssistThreadMetaPayload.decode(from: artifact.contentJSON) else { return nil }
            return AssistThreadSummary(
                id: payload.id,
                title: payload.title,
                status: payload.status,
                linkedCaptureIDs: payload.linkedCaptureIDs,
                createdAt: payload.createdAt,
                updatedAt: payload.updatedAt
            )
        }
        assistThreads = summaries.sorted { $0.updatedAt > $1.updatedAt }
        if let active = assistThreads.first(where: { $0.status == .active }) {
            activeAssistThreadID = active.id
        } else {
            activeAssistThreadID = nil
        }
    }

    private func saveAssistThread(_ summary: AssistThreadSummary) {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            assistThreadMetaType,
            summary.id as CVarArg
        )
        let existing = (try? context.fetch(request))?.first
        let entity = existing ?? ArtifactEntity(context: context)
        if existing == nil {
            entity.id = UUID()
            entity.createdAt = summary.createdAt
        }
        entity.artifactType = assistThreadMetaType
        entity.title = summary.title
        entity.sourceCaptureID = summary.id
        entity.status = summary.status.rawValue
        entity.contentJSON = AssistThreadMetaPayload(
            id: summary.id,
            title: summary.title,
            status: summary.status,
            linkedCaptureIDs: summary.linkedCaptureIDs,
            createdAt: summary.createdAt,
            updatedAt: summary.updatedAt
        ).encodedJSON() ?? "{}"
        entity.updatedAt = summary.updatedAt
        saveContext(operation: "save_assist_thread_meta")
    }

    private func loadAssistSession(threadID: UUID) {
        assistSessionMessages = loadAssistThreadMessages(threadID: threadID)
        assistDraftPayload = nil
        assistDraftErrorMessage = nil
        isAssistDraftVisible = false
        assistSplitSuggestionMessage = nil
        isAssistGenerating = false
    }

    private func loadAssistThreadMessages(threadID: UUID) -> [AssistSessionMessage] {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            assistThreadMessageType,
            threadID as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let artifacts = (try? context.fetch(request)) ?? []
        return artifacts.compactMap { artifact in
            guard let payload = AssistThreadMessagePayload.decode(from: artifact.contentJSON) else { return nil }
            return AssistSessionMessage(
                id: payload.id,
                role: payload.role,
                text: payload.text,
                createdAt: payload.createdAt
            )
        }
    }

    private func saveAssistThreadMessage(threadID: UUID, message: AssistSessionMessage) {
        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = assistThreadMessageType
        artifact.title = message.role.rawValue
        artifact.sourceCaptureID = threadID
        artifact.status = "done"
        artifact.contentJSON = AssistThreadMessagePayload(
            id: message.id,
            role: message.role,
            text: message.text,
            createdAt: message.createdAt
        ).encodedJSON() ?? "{}"
        artifact.createdAt = message.createdAt
        artifact.updatedAt = message.createdAt
        saveContext(operation: "save_assist_thread_message")
    }

    private func currentThreadLinkedCaptureIDs(threadID: UUID) -> [UUID] {
        assistThreads.first(where: { $0.id == threadID })?.linkedCaptureIDs ?? []
    }

    private func updateThreadLinkedCaptures(threadID: UUID, linkedCaptureIDs: [UUID]) {
        guard let current = assistThreads.first(where: { $0.id == threadID }) else { return }
        let updated = AssistThreadSummary(
            id: current.id,
            title: current.title,
            status: current.status,
            linkedCaptureIDs: linkedCaptureIDs,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
        saveAssistThread(updated)
        if let index = assistThreads.firstIndex(where: { $0.id == threadID }) {
            assistThreads[index] = updated
        }
    }

    private func closeThread(threadID: UUID) {
        guard let current = assistThreads.first(where: { $0.id == threadID }) else { return }
        let updated = AssistThreadSummary(
            id: current.id,
            title: current.title,
            status: .closed,
            linkedCaptureIDs: current.linkedCaptureIDs,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
        saveAssistThread(updated)
        if let index = assistThreads.firstIndex(where: { $0.id == threadID }) {
            assistThreads[index] = updated
        }
    }

    private func touchThread(threadID: UUID) {
        guard let current = assistThreads.first(where: { $0.id == threadID }) else { return }
        let updated = AssistThreadSummary(
            id: current.id,
            title: current.title,
            status: current.status,
            linkedCaptureIDs: current.linkedCaptureIDs,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
        saveAssistThread(updated)
        if let index = assistThreads.firstIndex(where: { $0.id == threadID }) {
            assistThreads[index] = updated
        }
    }

    private func closeActiveThreadIfNeeded() {
        guard let threadID = activeAssistThreadID else { return }
        closeThread(threadID: threadID)
    }

    private func shouldSuggestThreadSplit(for questionText: String, threadID: UUID) -> Bool {
        guard !currentThreadLinkedCaptureIDs(threadID: threadID).isEmpty else { return false }
        let userTexts = assistSessionMessages
            .filter { $0.role == .user }
            .map(\.text)
        guard userTexts.count >= 2 else { return false }
        let previous = userTexts[userTexts.count - 2]
        let overlap = lexicalOverlap(previous, questionText)
        return overlap < 0.18
    }

    private func lexicalOverlap(_ lhs: String, _ rhs: String) -> Double {
        let lhsTokens = Set(lhs.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init))
        let rhsTokens = Set(rhs.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init))
        guard !lhsTokens.isEmpty, !rhsTokens.isEmpty else { return 1 }
        let intersect = lhsTokens.intersection(rhsTokens).count
        let union = lhsTokens.union(rhsTokens).count
        return union == 0 ? 1 : Double(intersect) / Double(union)
    }

    private func applyRevision(to captureID: UUID, newText: String, threadID: UUID) {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }
        let cleanResult = CleanDefiller.clean(newText)
        let wasVoiceCapture = entity.inputType == CaptureInputType.voice.rawValue

        let previousRaw = entity.rawText
        let previousClean = entity.cleanText
        entity.rawText = newText
        entity.cleanText = cleanResult.cleanText
        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.ackTitle = nil
        entity.ackDetail = nil
        entity.atomsCount = 0
        entity.inputType = (wasVoiceCapture ? CaptureInputType.voice : .text).rawValue
        if !wasVoiceCapture {
            entity.audioPath = nil
            entity.transcriptText = nil
            entity.transcriptionStatus = nil
            entity.transcriptionError = nil
        }
        entity.atomizationError = nil
        entity.sourceThreadID = threadID
        atomStore.clearAtomsForCapture(captureID: captureID)
        clearAtomizationPayload(captureID: captureID)
        saveContext(operation: "apply_capture_revision")

        let payload = CaptureRevisionPayload(
            captureID: captureID,
            threadID: threadID,
            editedAt: Date(),
            previousRawText: previousRaw,
            previousCleanText: previousClean,
            updatedText: newText
        )
        saveCaptureRevision(payload)
        loadCaptures()
        postCaptureStateChanged(captureID: captureID)
        scheduleClean(captureID: captureID, sourceText: newText, forceAI: false)

        Task {
            await updateQuickAck(for: entity)
        }
    }

    private func saveCaptureRevision(_ payload: CaptureRevisionPayload) {
        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = captureRevisionType
        artifact.title = "capture_revision"
        artifact.sourceCaptureID = payload.captureID
        artifact.status = "done"
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.createdAt = payload.editedAt
        artifact.updatedAt = payload.editedAt
        saveContext(operation: "save_capture_revision")
    }

    private func formattedThreadTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: date)
    }

    private func updateQuickAck(for entity: CaptureEntity) async {
        let item = makeCaptureItem(from: entity, assistRecord: nil)

        do {
            // Add 10-second timeout to prevent indefinite blocking
            let result = try await withTimeout(seconds: 10) {
                try await self.aiService.quickAck(for: item)
            }
            entity.ackTitle = result.ackTitle
            entity.ackDetail = result.ackDetail
            entity.processingState = CaptureProcessingState.pendingSplit.rawValue
            entity.atomizationError = nil
            saveContext()
            loadCaptures()
            schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [entity.id])
        } catch {
            LogStore.shared.log("QuickAck failed: \(error.localizedDescription)", category: .ai)
            entity.ackTitle = "已记下"
            entity.ackDetail = "等待后续整理"
            entity.processingState = CaptureProcessingState.pendingSplit.rawValue
            entity.atomizationError = nil
            saveContext()
            loadCaptures()
            schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [entity.id])
        }
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    private struct TimeoutError: Error {}

    private func registerRecordingObservers() {
        let interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.isRecording else { return }
                guard let info = note.userInfo,
                      let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: rawType),
                      type == .began else { return }
                self.stopRecording(
                    rawText: "语音记录（未完成）",
                    noticeMessage: "检测到系统中断，录音已保存（未完成）"
                )
            }
        }

        let backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.isRecording else { return }
                self.stopRecording(
                    rawText: "语音记录（未完成）",
                    noticeMessage: "应用进入后台，录音已保存（未完成）"
                )
            }
        }

        notificationObservers.append(contentsOf: [interruptionObserver, backgroundObserver])
    }

    private func registerDebugObservers() {
        let repairObserver = NotificationCenter.default.addObserver(
            forName: .capturePendingAtomizationRequested,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.schedulePendingAtomizationIfPossible()
                self?.loadCaptures()
            }
        }

        notificationObservers.append(repairObserver)
    }

    private func scheduleRecordingAutoStop() {
        recordingAutoStopTask?.cancel()
        recordingAutoStopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.maxRecordingDurationNs ?? 0)
            guard let self else { return }
            guard self.isRecording else { return }
            self.stopRecording(rawText: "语音记录（未完成）", noticeMessage: "录音达到 5 分钟上限，已自动保存")
        }
    }

    private func scheduleRecordingPreStopWarning() {
        recordingWarningTask?.cancel()
        guard maxRecordingDurationNs > recordingWarningLeadNs else { return }
        let delay = maxRecordingDurationNs - recordingWarningLeadNs
        recordingWarningTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delay)
            guard let self else { return }
            guard self.isRecording else { return }
            self.showRecordingNotice("录音将在 10 秒后自动停止并保存", autoHideAfterNs: 9_000_000_000)
        }
    }

    private func startRecordingLevelMonitoring() {
        recordingLevelTask?.cancel()
        recordingLevelTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                guard self.isRecording else {
                    self.recordingLevel = 0
                    return
                }
                self.recordingLevel = max(0.12, self.voiceRecorder.currentNormalizedPower())
                try? await Task.sleep(nanoseconds: 120_000_000)
            }
        }
    }

    private func showRecordingNotice(_ message: String, autoHideAfterNs: UInt64 = 3_000_000_000) {
        recordingNoticeTask?.cancel()
        recordingNoticeMessage = message
        recordingNoticeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: autoHideAfterNs)
            guard let self else { return }
            self.recordingNoticeMessage = nil
        }
    }

    private func restorePendingTranscriptions(from entities: [CaptureEntity]) {
        let pendingCaptureIDs = entities.compactMap { entity -> UUID? in
            guard entity.inputType == CaptureInputType.voice.rawValue else { return nil }
            guard let statusRaw = entity.transcriptionStatus else { return nil }
            guard statusRaw == TranscriptionStatus.pending.rawValue || statusRaw == TranscriptionStatus.offline.rawValue else {
                return nil
            }
            return entity.id
        }

        for captureID in pendingCaptureIDs where transcriptionTasks[captureID] == nil {
            enqueueTranscription(captureID: captureID, shouldResetToPending: false)
        }
    }

    private func enqueueTranscription(captureID: UUID, shouldResetToPending: Bool) {
        transcriptionTasks[captureID]?.cancel()
        transcriptionDebugStore.record(
            phase: "queue",
            status: "enqueued",
            provider: transcriptionProviderPathLabel,
            captureID: captureID,
            message: shouldResetToPending ? "retry enqueued" : "new capture enqueued"
        )
        transcriptionTasks[captureID] = Task { [weak self] in
            await self?.runTranscriptionQueue(captureID: captureID, shouldResetToPending: shouldResetToPending)
        }
    }

    private func runTranscriptionQueue(captureID: UUID, shouldResetToPending: Bool) async {
        defer { transcriptionTasks[captureID] = nil }
        var retryAttempts = 0

        if shouldResetToPending, let entity = fetchCaptureEntity(captureID: captureID) {
            entity.transcriptionStatus = TranscriptionStatus.pending.rawValue
            entity.transcriptionError = nil
            saveContext()
            loadCaptures()
            transcriptionDebugStore.record(
                phase: "queue",
                status: "pending",
                provider: transcriptionProviderPathLabel,
                captureID: captureID,
                message: "reset to pending"
            )
        }

        while !Task.isCancelled {
            guard let entity = fetchCaptureEntity(captureID: captureID) else { return }

            guard let path = entity.audioPath, !path.isEmpty, FileManager.default.fileExists(atPath: path) else {
                entity.transcriptText = nil
                entity.cleanText = nil
                entity.transcriptionStatus = TranscriptionStatus.failed.rawValue
                entity.transcriptionError = "音频文件不存在或已被清理"
                saveContext()
                loadCaptures()
                transcriptionDebugStore.record(
                    phase: "queue",
                    status: "failed",
                    provider: transcriptionProviderPathLabel,
                    captureID: captureID,
                    error: VoiceTranscriptionError.audioFileMissing
                )
                LogStore.shared.log("Transcription failed: missing audio file for \(captureID.uuidString)", category: .jobs)
                return
            }

            if FeatureFlags.shared.isTranscriptionOfflineSimulated {
                entity.transcriptionStatus = TranscriptionStatus.offline.rawValue
                entity.transcriptionError = "已开启离线模拟，系统将稍后自动重试"
                saveContext()
                loadCaptures()
                transcriptionDebugStore.record(
                    phase: "queue",
                    status: "offline",
                    provider: transcriptionProviderPathLabel,
                    captureID: captureID,
                    message: "offline simulation enabled"
                )
                try? await Task.sleep(nanoseconds: transcriptionPollIntervalNs)
                continue
            }

            entity.transcriptionStatus = TranscriptionStatus.pending.rawValue
            entity.transcriptionError = nil
            saveContext()
            loadCaptures()
            transcriptionDebugStore.record(
                phase: "queue",
                status: "pending",
                provider: transcriptionProviderPathLabel,
                captureID: captureID,
                message: "transcription attempt started"
            )

            if FeatureFlags.shared.isTranscriptionFailureSimulated {
                entity.transcriptText = nil
                entity.cleanText = nil
                entity.transcriptionStatus = TranscriptionStatus.failed.rawValue
                entity.transcriptionError = "已开启失败模拟（DevTools）"
                saveContext()
                loadCaptures()
                transcriptionDebugStore.record(
                    phase: "queue",
                    status: "failed",
                    provider: transcriptionProviderPathLabel,
                    captureID: captureID,
                    message: "failure simulation enabled"
                )
                return
            }

            do {
                let transcript = try await withTimeout(seconds: transcriptionTimeoutSeconds) {
                    try await self.transcriptionService.transcribeAudio(at: URL(fileURLWithPath: path))
                }

                guard !Task.isCancelled else { return }
                let cleanResult = await self.resolveCleanResult(for: transcript, forceAI: false)
                entity.transcriptText = transcript
                entity.cleanText = cleanResult.cleanText
                entity.transcriptionStatus = TranscriptionStatus.completed.rawValue
                entity.transcriptionError = nil
                let captureMode = CaptureInputMode(rawValue: entity.mode ?? "") ?? .log
                entity.processingState = captureMode == .assist
                    ? CaptureProcessingState.cleanReady.rawValue
                    : CaptureProcessingState.pendingSplit.rawValue
                entity.atomizationError = nil
                saveContext()
                loadCaptures()
                self.postCaptureStateChanged(captureID: captureID)
                if captureMode == .assist {
                    self.handleCompletedAssistVoiceCapture(entity: entity, transcript: cleanResult.cleanText)
                }
                transcriptionDebugStore.record(
                    phase: "queue",
                    status: "completed",
                    provider: transcriptionProviderPathLabel,
                    captureID: captureID
                )
            } catch {
                guard !Task.isCancelled else { return }

                if let transcriptionError = error as? VoiceTranscriptionError,
                   transcriptionError == .permissionDenied {
                    speechPermissionMessage = "语音识别权限未开启。请在“设置 > Life Narattor > 语音识别”中开启后重试。"
                    isSpeechPermissionAlertPresented = true
                }

                if shouldRetryTranscription(for: error) {
                    retryAttempts += 1
                    if retryAttempts > transcriptionMaxRetryAttempts {
                        entity.transcriptText = nil
                        entity.cleanText = nil
                        entity.transcriptionStatus = TranscriptionStatus.failed.rawValue
                        entity.transcriptionError = transcriptionRetryExhaustedReason(for: error)
                        saveContext()
                        loadCaptures()
                        transcriptionDebugStore.record(
                            phase: "queue",
                            status: "failed",
                            provider: transcriptionProviderPathLabel,
                            captureID: captureID,
                            message: entity.transcriptionError,
                            error: error
                        )
                        LogStore.shared.log("Transcription failed after max retries: \(error.localizedDescription)", category: .jobs)
                        return
                    }

                    let retryDelay = retryDelayNanoseconds(forAttempt: retryAttempts)
                    entity.transcriptionStatus = TranscriptionStatus.offline.rawValue
                    entity.transcriptionError = transcriptionRetryReason(
                        for: error,
                        attempt: retryAttempts,
                        maxAttempts: transcriptionMaxRetryAttempts,
                        retryDelayNs: retryDelay
                    )
                    saveContext()
                    loadCaptures()
                    transcriptionDebugStore.record(
                        phase: "queue",
                        status: "retry",
                        provider: transcriptionProviderPathLabel,
                        captureID: captureID,
                        message: entity.transcriptionError,
                        error: error
                    )
                    try? await Task.sleep(nanoseconds: retryDelay)
                    continue
                }

                entity.transcriptText = nil
                entity.cleanText = nil
                entity.transcriptionStatus = TranscriptionStatus.failed.rawValue
                entity.transcriptionError = transcriptionFailureReason(for: error)
                saveContext()
                loadCaptures()
                transcriptionDebugStore.record(
                    phase: "queue",
                    status: "failed",
                    provider: transcriptionProviderPathLabel,
                    captureID: captureID,
                    message: transcriptionFailureReason(for: error),
                    error: error
                )
                LogStore.shared.log("Transcription failed: \(error.localizedDescription)", category: .jobs)
                return
            }

            retryAttempts = 0

            if entity.atomsCount == 0, entity.cleanText != nil {
                saveContext()
                loadCaptures()
                self.postCaptureStateChanged(captureID: captureID)
                schedulePendingAtomizationIfPossible(prioritizedCaptureIDs: [entity.id])
            }
            return
        }
    }

    private func shouldRetryTranscription(for error: Error) -> Bool {
        if error is TimeoutError {
            return true
        }

        if let transcriptionError = error as? VoiceTranscriptionError {
            switch transcriptionError {
            case .recognizerUnavailable:
                return true
            case .permissionDenied, .emptyResult, .audioFileMissing:
                return false
            }
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return [
                NSURLErrorNotConnectedToInternet,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorTimedOut
            ].contains(nsError.code)
        }

        return false
    }

    private func transcriptionRetryReason(
        for error: Error,
        attempt: Int,
        maxAttempts: Int,
        retryDelayNs: UInt64
    ) -> String {
        let delaySeconds = max(1, Int(retryDelayNs / 1_000_000_000))
        let attemptText = "（第\(attempt)/\(maxAttempts)次，\(delaySeconds)秒后重试）"

        if error is TimeoutError {
            return "转写超时，稍后自动重试\(attemptText)"
        }

        if let transcriptionError = error as? VoiceTranscriptionError,
           transcriptionError == .recognizerUnavailable {
            return "语音识别服务暂不可用，稍后自动重试\(attemptText)"
        }

        if let aiError = error as? AIServiceError,
           case .httpStatus(let code) = aiError {
            return "转写服务暂不可用（HTTP \(code)），稍后自动重试\(attemptText)"
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return "网络异常，稍后自动重试\(attemptText)"
        }

        return "服务暂不可用，稍后自动重试\(attemptText)"
    }

    private func transcriptionRetryExhaustedReason(for error: Error) -> String {
        if let aiError = error as? AIServiceError,
           case .httpStatus(let code) = aiError {
            if code == 402 {
                return "本月免费转写额度已用完，下月会自动恢复。"
            }
            return "转写重试已达上限（\(transcriptionMaxRetryAttempts)次，HTTP \(code)）"
        }
        return "转写重试已达上限（\(transcriptionMaxRetryAttempts)次）"
    }

    private func assistDraftFailureReason(for error: Error) -> String {
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .missingAPIKey:
                return "整理记录失败：AI 服务暂时不可用"
            case .invalidResponse:
                return "整理记录失败：AI 返回内容无法解析"
            case .httpStatus(let code):
                if code == 402 {
                    return "本月免费 AI 额度已用完，下月会自动恢复。记录功能仍可继续使用。"
                }
                return "整理记录失败：AI 服务异常（HTTP \(code)）"
            case .emptyResponse:
                return "整理记录失败：AI 返回为空"
            case .unsupported:
                return "整理记录失败：当前服务不支持该操作"
            }
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return "整理记录失败：网络异常，请重试"
        }

        return "整理记录失败：\(error.localizedDescription)"
    }

    private func retryDelayNanoseconds(forAttempt attempt: Int) -> UInt64 {
        let boundedAttempt = max(1, min(attempt, 16))
        let multiplier = UInt64(1) << UInt64(boundedAttempt - 1)
        let delay = transcriptionRetryBaseDelayNs * multiplier
        return min(delay, transcriptionRetryMaxDelayNs)
    }

    private func transcriptionFailureReason(for error: Error) -> String {
        if let transcriptionError = error as? VoiceTranscriptionError {
            switch transcriptionError {
            case .permissionDenied:
                return "语音识别权限未开启"
            case .emptyResult:
                return "未识别到清晰语音，请靠近麦克风重试"
            case .audioFileMissing:
                return "音频文件不存在或已被清理"
            case .recognizerUnavailable:
                return "语音识别服务暂不可用"
            }
        }

        if error is TimeoutError {
            return "转写超时，请稍后重试"
        }

        if let aiError = error as? AIServiceError {
            switch aiError {
            case .missingAPIKey:
                return "转写服务暂时不可用"
            case .invalidResponse:
                return "转写服务返回异常响应"
            case .httpStatus(let code):
                if code == 402 {
                    return "本月免费转写额度已用完，下月会自动恢复。"
                }
                return "转写服务异常（HTTP \(code)）"
            case .emptyResponse:
                return "转写结果为空，请重试"
            case .unsupported:
                return "当前服务不支持转写"
            }
        }

        return "转写失败，请重试"
    }

    private func handleCompletedAssistVoiceCapture(entity: CaptureEntity, transcript: String) {
        let questionText = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !questionText.isEmpty else {
            showRecordingNotice("语音已转写，但没有识别到可发送给助手的内容")
            return
        }

        let threadID = entity.sourceThreadID ?? activeAssistThreadID
        if let threadID {
            if activeAssistThreadID != threadID {
                openAssistThread(threadID)
            }
            touchThread(threadID: threadID)
        } else {
            ensureActiveAssistThread()
        }

        showRecordingNotice("语音转写完成，已发送给助手")
        startAssistSessionTurn(questionText: questionText)
    }

    private func fetchCaptureEntity(captureID: UUID) -> CaptureEntity? {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)
        return try? context.fetch(request).first
    }

    private func updateAssistArchive(for entity: CaptureEntity, questionText: String) async {
        let item = makeCaptureItem(from: entity, assistRecord: nil)

        do {
            let payload = try await aiService.assistArchive(for: item, questionText: questionText)
            saveArtifact(for: entity, payload: payload)
            saveContext()
            loadCaptures()
        } catch {
            let fallback = AssistArchivePayload(
                reply: "整理失败，稍后再试。",
                card: AssistArchiveCard(
                    title: "未能生成卡片",
                    context: "请求失败",
                    keyPoints: [],
                    nextSteps: [],
                    tagSuggestions: [],
                    confidence: "low"
                ),
                turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 0)
            )
            saveArtifact(for: entity, payload: fallback)
            saveContext()
            loadCaptures()
        }
    }

    private func makeCaptureItem(
        from entity: CaptureEntity,
        assistRecord: AssistArchiveRecord?,
        revisionCount: Int = 0
    ) -> CaptureItem {
        let mode = entity.resolvedInputMode
        let state = entity.resolvedReviewProcessingState
        let inputType = CaptureInputType(rawValue: entity.inputType ?? "") ?? .text
        let transcriptionStatus = TranscriptionStatus(rawValue: entity.transcriptionStatus ?? "")

        return CaptureItem(
            id: entity.id,
            createdAt: entity.createdAt,
            rawText: entity.rawText,
            cleanText: entity.cleanText,
            ackTitle: entity.ackTitle,
            ackDetail: entity.ackDetail,
            dayPart: dayPart(for: entity.createdAt, fallback: entity.dayPart),
            mode: mode,
            assistRecord: assistRecord,
            atomsCount: Int(entity.atomsCount),
            processingState: state,
            inputType: inputType,
            audioPath: entity.audioPath,
            transcriptText: entity.transcriptText,
            transcriptionStatus: transcriptionStatus,
            transcriptionErrorReason: entity.transcriptionError,
            atomizationErrorReason: entity.atomizationError,
            isTranscriptionActive: transcriptionTasks[entity.id] != nil,
            sourceThreadID: entity.sourceThreadID,
            revisionCount: revisionCount
        )
    }

    private func resolveProcessingState(from entity: CaptureEntity) -> CaptureProcessingState {
        entity.resolvedReviewProcessingState
    }

    private func loadArtifacts(for captureIds: [UUID]) -> [UUID: AssistArchiveRecord] {
        guard !captureIds.isEmpty else { return [:] }

        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID IN %@",
            "assist_archive_card",
            captureIds
        )

        do {
            let artifacts = try context.fetch(request)
            return artifacts.reduce(into: [:]) { result, artifact in
                guard let payload = AssistArchivePayload.decode(from: artifact.contentJSON) else { return }
                let status = AssistArchiveStatus(rawValue: artifact.status) ?? .draft
                result[artifact.sourceCaptureID] = AssistArchiveRecord(payload: payload, status: status)
            }
        } catch {
            return [:]
        }
    }

    private func loadRevisionCounts(for captureIds: [UUID]) -> [UUID: Int] {
        guard !captureIds.isEmpty else { return [:] }
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID IN %@",
            captureRevisionType,
            captureIds
        )
        let artifacts = (try? context.fetch(request)) ?? []
        return artifacts.reduce(into: [:]) { result, artifact in
            result[artifact.sourceCaptureID, default: 0] += 1
        }
    }

    private func saveArtifact(for entity: CaptureEntity, payload: AssistArchivePayload) {
        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = "assist_archive_card"
        artifact.title = payload.card.title
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.sourceCaptureID = entity.id
        artifact.status = AssistArchiveStatus.draft.rawValue
        artifact.createdAt = Date()
        artifact.updatedAt = Date()
    }

    private func fetchArtifact(captureID: UUID) -> ArtifactEntity? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "sourceCaptureID == %@", captureID as CVarArg)
        return try? context.fetch(request).first
    }

    private func clearAtomizationPayload(captureID: UUID) {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            atomizationPayloadArtifactType,
            captureID as CVarArg
        )
        let artifacts = (try? context.fetch(request)) ?? []
        artifacts.forEach { context.delete($0) }
    }

    private func applyVoiceCaptureDraft(_ draft: VoiceCaptureDraft, to entity: CaptureEntity) {
        entity.id = draft.id
        entity.createdAt = draft.createdAt
        entity.rawText = draft.rawText
        entity.cleanText = nil
        entity.dayPart = draft.dayPart.rawValue
        entity.mode = draft.mode.rawValue
        entity.isHiddenFromFeed = false
        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.atomsCount = 0
        entity.inputType = CaptureInputType.voice.rawValue
        entity.audioPath = draft.audioPath
        entity.transcriptionStatus = TranscriptionStatus.pending.rawValue
        entity.transcriptText = nil
        entity.transcriptionError = nil
        entity.sourceThreadID = draft.sourceThreadID
    }

    private func persistVoiceCapture(_ draft: VoiceCaptureDraft) -> Bool {
        let entity = CaptureEntity(context: context)
        applyVoiceCaptureDraft(draft, to: entity)
        if saveContext(operation: "voice_capture_main_save") {
            return true
        }

        guard let coordinator = context.persistentStoreCoordinator else {
            LogStore.shared.log("Voice capture fallback unavailable: missing persistentStoreCoordinator", category: .jobs)
            return false
        }

        let fallbackContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        fallbackContext.persistentStoreCoordinator = coordinator

        var fallbackSaved = false
        fallbackContext.performAndWait {
            let fallbackEntity = CaptureEntity(context: fallbackContext)
            applyVoiceCaptureDraft(draft, to: fallbackEntity)
            do {
                try fallbackContext.save()
                fallbackSaved = true
            } catch {
                let nsError = error as NSError
                LogStore.shared.log(
                    "Voice capture fallback save failed: [\(nsError.domain):\(nsError.code)] \(nsError.localizedDescription)",
                    category: .jobs
                )
                fallbackContext.rollback()
            }
        }

        if fallbackSaved {
            context.refreshAllObjects()
        }
        return fallbackSaved
    }

    @discardableResult
    private func saveContext(operation: String = "context_save") -> Bool {
        do {
            try context.save()
            return true
        } catch {
            let nsError = error as NSError
            LogStore.shared.log(
                "CoreData save failed (\(operation)): [\(nsError.domain):\(nsError.code)] \(nsError.localizedDescription)",
                category: .jobs
            )
            context.rollback()
            return false
        }
    }

    private var transcriptionProviderPathLabel: String {
        let primary = transcriptionDebugStore.primaryProviderLabel(featureFlags: FeatureFlags.shared)
        if FeatureFlags.shared.isAITranscriptionPreferred {
            return "\(primary)->local.speech(fallback)"
        }
        return "local.speech"
    }

    private func dayPart(for date: Date, fallback: String?) -> DayPart {
        if let fallback = fallback, let stored = DayPart(rawValue: fallback) {
            return stored
        }

        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
    }
}

private enum AssistIntentKind {
    case record
    case analyze
    case execute
    case decision
    case reflect
    case unknown
}

private enum PronunciationFocus {
    case onset
    case vowel
    case ending
}

private struct AssistReplyContract {
    let acknowledge: String
    let coreReason: String
    let microAction: String
    let successCriterion: String
    let followUpQuestion: String
}

struct AssistSessionMessage: Identifiable, Equatable {
    let id: UUID
    let role: AssistSessionRole
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: AssistSessionRole, text: String, createdAt: Date) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

enum AssistSessionRole: String, Codable {
    case user
    case assistant
}

enum AssistThreadStatus: String, Codable {
    case active
    case closed
}

struct AssistThreadSummary: Identifiable, Equatable {
    let id: UUID
    let title: String
    let status: AssistThreadStatus
    let linkedCaptureIDs: [UUID]
    let createdAt: Date
    let updatedAt: Date
}

private struct AssistThreadMetaPayload: Codable {
    let id: UUID
    let title: String
    let status: AssistThreadStatus
    let linkedCaptureIDs: [UUID]
    let createdAt: Date
    let updatedAt: Date

    func encodedJSON() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from json: String) -> AssistThreadMetaPayload? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AssistThreadMetaPayload.self, from: data)
    }
}

private struct AssistThreadMessagePayload: Codable {
    let id: UUID
    let role: AssistSessionRole
    let text: String
    let createdAt: Date

    func encodedJSON() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from json: String) -> AssistThreadMessagePayload? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AssistThreadMessagePayload.self, from: data)
    }
}

private struct CaptureRevisionPayload: Codable {
    let captureID: UUID
    let threadID: UUID
    let editedAt: Date
    let previousRawText: String
    let previousCleanText: String?
    let updatedText: String

    func encodedJSON() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

private struct VoiceCaptureDraft {
    let id: UUID
    let createdAt: Date
    let rawText: String
    let dayPart: DayPart
    let mode: CaptureInputMode
    let audioPath: String
    let sourceThreadID: UUID?
}

private final class VoiceRecorderController: NSObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private var lastRecordingURL: URL?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startRecording() throws -> URL {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let url = Self.makeRecordingURL()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()
        guard recorder.record() else {
            throw NSError(domain: "VoiceRecorderController", code: -1)
        }

        self.recorder = recorder
        lastRecordingURL = url
        return url
    }

    func stopRecording() -> URL? {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return lastRecordingURL
    }

    func cancelRecording() {
        recorder?.stop()
        recorder = nil
        if let url = lastRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        lastRecordingURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func currentNormalizedPower() -> Double {
        guard let recorder else { return 0 }
        recorder.updateMeters()
        let averagePower = Double(recorder.averagePower(forChannel: 0))
        let clamped = max(-50.0, min(0.0, averagePower))
        let normalized = (clamped + 50.0) / 50.0
        return max(0.0, min(1.0, normalized))
    }

    private static func makeRecordingURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = "recording-\(UUID().uuidString).m4a"
        return directory.appendingPathComponent(filename)
    }
}

@MainActor
private final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "LifeNarrator.NetworkMonitor")
    private var handlers: [UUID: @MainActor (Bool) -> Void] = [:]

    private(set) var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                let connected = path.status == .satisfied
                self.isConnected = connected
                for handler in self.handlers.values {
                    handler(connected)
                }
            }
        }
        monitor.start(queue: queue)
    }

    func addListener(_ handler: @escaping @MainActor (Bool) -> Void) -> UUID {
        let id = UUID()
        handlers[id] = handler
        handler(isConnected)
        return id
    }
}

extension Notification.Name {
    static let captureProcessingStateChanged = Notification.Name("captureProcessingStateChanged")
    static let capturePendingAtomizationRequested = Notification.Name("capturePendingAtomizationRequested")
}
