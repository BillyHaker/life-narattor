import Foundation
import Speech

protocol VoiceTranscribing {
    func transcribeAudio(at fileURL: URL) async throws -> String
}

enum VoiceTranscriptionError: Error, Equatable {
    case permissionDenied
    case recognizerUnavailable
    case emptyResult
    case audioFileMissing
}

enum SpeechAuthorizationManager {
    static func requestAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return status == .authorized
    }
}

final class HybridVoiceTranscriptionService: VoiceTranscribing {
    private let aiService: AIService
    private let fallback: VoiceTranscribing
    private let featureFlags: FeatureFlags
    private let debugStore: TranscriptionDebugStore

    init(
        aiService: AIService,
        fallback: VoiceTranscribing = SystemSpeechTranscriptionService(),
        featureFlags: FeatureFlags = .shared,
        debugStore: TranscriptionDebugStore = .shared
    ) {
        self.aiService = aiService
        self.fallback = fallback
        self.featureFlags = featureFlags
        self.debugStore = debugStore
    }

    func transcribeAudio(at fileURL: URL) async throws -> String {
        let aiProvider = debugStore.providerLabel(for: aiService)

        guard featureFlags.isAITranscriptionPreferred else {
            debugStore.record(
                phase: "transcribe",
                status: "started",
                provider: "local.speech",
                message: "AI preference disabled"
            )
            do {
                let transcript = try await fallback.transcribeAudio(at: fileURL)
                debugStore.record(
                    phase: "transcribe",
                    status: "completed",
                    provider: "local.speech"
                )
                return transcript
            } catch {
                debugStore.record(
                    phase: "transcribe",
                    status: "failed",
                    provider: "local.speech",
                    error: error
                )
                throw error
            }
        }

        debugStore.record(
            phase: "transcribe",
            status: "started",
            provider: aiProvider,
            message: "AI primary path"
        )

        do {
            let transcript = try await aiService.transcribeAudio(
                fileURL: fileURL,
                locale: Locale.current.identifier
            )
            let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                throw VoiceTranscriptionError.emptyResult
            }
            debugStore.record(
                phase: "transcribe",
                status: "completed",
                provider: aiProvider
            )
            return trimmed
        } catch {
#if DEBUG
            LogStore.shared.log("AI transcription fallback to local: \(error.localizedDescription)", category: .ai)
            debugStore.record(
                phase: "fallback",
                status: "fallback",
                provider: aiProvider,
                message: "AI failed, fallback to local speech",
                error: error
            )
            do {
                let transcript = try await fallback.transcribeAudio(at: fileURL)
                debugStore.record(
                    phase: "fallback",
                    status: "completed",
                    provider: "local.speech",
                    message: "fallback succeeded"
                )
                return transcript
            } catch {
                debugStore.record(
                    phase: "fallback",
                    status: "failed",
                    provider: "local.speech",
                    message: "fallback failed",
                    error: error
                )
                throw error
            }
#else
            LogStore.shared.log("AI transcription failed: \(error.localizedDescription)", category: .ai)
            debugStore.record(
                phase: "transcribe",
                status: "failed",
                provider: aiProvider,
                message: "AI transcription failed; backend transcription is required in beta builds",
                error: error
            )
            throw error
#endif
        }
    }
}

final class SystemSpeechTranscriptionService: VoiceTranscribing {
    private let preferredLocales: [Locale] = [
        Locale(identifier: "zh-CN"),
        Locale(identifier: "en-US"),
        .current
    ]

    func transcribeAudio(at fileURL: URL) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw VoiceTranscriptionError.audioFileMissing
        }

        let authorized = await SpeechAuthorizationManager.requestAuthorization()
        guard authorized else {
            throw VoiceTranscriptionError.permissionDenied
        }

        guard let recognizer = makeAvailableRecognizer() else {
            throw VoiceTranscriptionError.recognizerUnavailable
        }

        return try await recognize(fileURL: fileURL, recognizer: recognizer)
    }
    private func makeAvailableRecognizer() -> SFSpeechRecognizer? {
        for locale in preferredLocales {
            guard let recognizer = SFSpeechRecognizer(locale: locale) else { continue }
            if recognizer.isAvailable {
                return recognizer
            }
        }
        if let fallback = SFSpeechRecognizer(locale: .current), fallback.isAvailable {
            return fallback
        }
        return nil
    }

    private func recognize(fileURL: URL, recognizer: SFSpeechRecognizer) async throws -> String {
        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        request.shouldReportPartialResults = false
        request.addsPunctuation = true

        let box = RecognitionTaskBox()
        return try await withTaskCancellationHandler {
            box.task?.cancel()
            box.task = nil
        } operation: {
            try await withCheckedThrowingContinuation { continuation in
                var hasResumed = false

                box.task = recognizer.recognitionTask(with: request) { result, error in
                    guard !hasResumed else { return }

                    if let error {
                        hasResumed = true
                        box.task?.cancel()
                        box.task = nil
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let result, result.isFinal else { return }
                    let transcript = result.bestTranscription.formattedString
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    hasResumed = true
                    box.task?.cancel()
                    box.task = nil
                    if transcript.isEmpty {
                        continuation.resume(throwing: VoiceTranscriptionError.emptyResult)
                    } else {
                        continuation.resume(returning: transcript)
                    }
                }
            }
        }
    }
}

private final class RecognitionTaskBox {
    var task: SFSpeechRecognitionTask?
}
