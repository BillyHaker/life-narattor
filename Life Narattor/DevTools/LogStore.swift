import Foundation
import Combine

final class LogStore: ObservableObject {
    static let shared = LogStore()

    private let maxEntries = 500
    @Published private(set) var entries: [LogEntry] = []

    func log(_ message: String, category: LogCategory) {
        let entry = LogEntry(id: UUID(), timestamp: Date(), category: category, message: message)
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    func clear() {
        entries.removeAll()
    }
}

struct LogEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let category: LogCategory
    let message: String
}

enum LogCategory: String, CaseIterable, Identifiable {
    case ui
    case db
    case network
    case ai
    case jobs

    var id: String { rawValue }

    var title: String {
        rawValue.uppercased()
    }
}

struct TranscriptionDebugEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let phase: String
    let status: String
    let provider: String
    let captureID: String?
    let code: String?
    let message: String?
}

final class TranscriptionDebugStore: ObservableObject {
    static let shared = TranscriptionDebugStore()

    private let maxEntries = 200
    @Published private(set) var events: [TranscriptionDebugEvent] = []
    @Published private(set) var lastFallbackReason: String?
    @Published private(set) var lastErrorCode: String?

    init() {
        events = []
        lastFallbackReason = nil
        lastErrorCode = nil
    }

    var latestEvent: TranscriptionDebugEvent? {
        events.first
    }

    func clear() {
        events.removeAll()
        lastFallbackReason = nil
        lastErrorCode = nil
    }

    func record(
        phase: String,
        status: String,
        provider: String,
        captureID: UUID? = nil,
        message: String? = nil,
        error: Error? = nil
    ) {
        let code = normalizedCode(from: error)
        if status == "fallback" {
            lastFallbackReason = message ?? error?.localizedDescription
        }
        if let code {
            lastErrorCode = code
        }

        let event = TranscriptionDebugEvent(
            id: UUID(),
            timestamp: Date(),
            phase: phase,
            status: status,
            provider: provider,
            captureID: captureID?.uuidString,
            code: code,
            message: message
        )
        events.insert(event, at: 0)
        if events.count > maxEntries {
            events.removeLast(events.count - maxEntries)
        }
    }

    func primaryProviderLabel(featureFlags: FeatureFlags = .shared) -> String {
        guard featureFlags.isAITranscriptionPreferred else { return "local.speech" }
        if BackendConfig.baseURL != nil {
            return "ai.backend"
        }
        if let apiKey = OpenAIConfig.apiKey, !apiKey.isEmpty {
            return "ai.openai"
        }
        return "ai.unavailable"
    }

    func providerLabel(for aiService: AIService) -> String {
        let typeName = String(describing: type(of: aiService))
        if typeName.contains("BackendAIService") {
            return "ai.backend"
        }
        if typeName.contains("OpenAIService") {
            return "ai.openai"
        }
        if typeName.contains("UnavailableAIService") {
            return "ai.unavailable"
        }
        return "ai.unknown"
    }

    private func normalizedCode(from error: Error?) -> String? {
        guard let error else { return nil }

        if let aiError = error as? AIServiceError {
            switch aiError {
            case .missingAPIKey:
                return "ai.missing_api_key"
            case .invalidResponse:
                return "ai.invalid_response"
            case .httpStatus(let status):
                return "ai.http.\(status)"
            case .emptyResponse:
                return "ai.empty_response"
            case .unsupported:
                return "ai.unsupported"
            }
        }

        if let transcriptionError = error as? VoiceTranscriptionError {
            switch transcriptionError {
            case .permissionDenied:
                return "voice.permission_denied"
            case .recognizerUnavailable:
                return "voice.recognizer_unavailable"
            case .emptyResult:
                return "voice.empty_result"
            case .audioFileMissing:
                return "voice.audio_missing"
            }
        }

        if String(describing: type(of: error)).contains("TimeoutError") {
            return "transcription.timeout"
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return "url.\(nsError.code)"
        }

        return "\(nsError.domain).\(nsError.code)"
    }
}
