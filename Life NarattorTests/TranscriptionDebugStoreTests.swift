import Foundation
import Testing
@testable import Life_Narattor

private final class MockAIService: AIService {
    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult {
        throw AIServiceError.unsupported
    }

    func cleanTranscript(text: String, forceAI: Bool) async throws -> CleanDefillerResult {
        throw AIServiceError.unsupported
    }

    func chatReply(for capture: CaptureItem, questionText: String) async throws -> String {
        throw AIServiceError.unsupported
    }

    func analyzeFocusedEvidence(_ bundle: FocusedEvidenceBundle, followupQuestion: String?) async throws -> String {
        throw AIServiceError.unsupported
    }

    func analyzeNarrativeMaterial(_ material: NarrativeMaterial, periodName: String, followupQuestion: String?) async throws -> String {
        throw AIServiceError.unsupported
    }

    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload {
        throw AIServiceError.unsupported
    }

    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle {
        throw AIServiceError.unsupported
    }

    func atomize(capture: CaptureItem, tagLibrary: TagLibrary) async throws -> AtomizeResult {
        throw AIServiceError.unsupported
    }

    func suggestTags(atomization: AtomizeResult, tagLibrary: TagLibrary) async throws -> TagSuggestionResult {
        throw AIServiceError.unsupported
    }

    func clusterHiddenTags(_ tags: [HiddenTagInventoryItem]) async throws -> HiddenTagClusterResult {
        throw AIServiceError.unsupported
    }

    func normalizeHiddenTags(in bucket: HiddenTagBucket, tags: [HiddenTagInventoryItem]) async throws -> [HiddenTagCanonicalMapping] {
        throw AIServiceError.unsupported
    }

    func transcribeAudio(fileURL: URL, locale: String?) async throws -> String {
        throw AIServiceError.unsupported
    }
}

struct TranscriptionDebugStoreTests {
    @Test("record fallback updates latest reason and error code")
    func fallbackUpdatesSummary() {
        let store = TranscriptionDebugStore()
        store.clear()

        store.record(
            phase: "fallback",
            status: "fallback",
            provider: "ai.backend",
            message: "AI failed, fallback to local speech",
            error: AIServiceError.httpStatus(503)
        )

        #expect(store.lastFallbackReason == "AI failed, fallback to local speech")
        #expect(store.lastErrorCode == "ai.http.503")
        #expect(store.latestEvent?.status == "fallback")
    }

    @Test("record voice error normalizes to voice code")
    func voiceErrorNormalization() {
        let store = TranscriptionDebugStore()
        store.clear()

        store.record(
            phase: "queue",
            status: "failed",
            provider: "local.speech",
            error: VoiceTranscriptionError.permissionDenied
        )

        #expect(store.lastErrorCode == "voice.permission_denied")
        #expect(store.latestEvent?.code == "voice.permission_denied")
    }

    @Test("provider label resolves concrete AI service type")
    func providerLabelResolution() {
        let store = TranscriptionDebugStore()
        store.clear()

        let mock = MockAIService()
        let label = store.providerLabel(for: mock)

        #expect(label == "ai.mock")
    }
}
