import Testing
@testable import Life_Narattor

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
    @MainActor
    func providerLabelResolution() {
        let store = TranscriptionDebugStore()
        store.clear()

        let label = store.providerLabel(for: UnavailableAIService())

        #expect(label == "ai.unavailable")
    }
}
