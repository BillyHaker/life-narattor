import Foundation
import Observation

@Observable
final class AIDebugStore {
    static let shared = AIDebugStore()

    private let maxEntries = 100
    private(set) var entries: [AIDebugEntry] = []

    func record(_ entry: AIDebugEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    func clear() {
        entries.removeAll()
    }
}

struct AIDebugEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let operation: String
    let model: String
    let status: String
    let durationMs: Int
    let requestBody: String
    let responseBody: String
    let errorMessage: String?
}

enum AIDebugRedactor {
    static func redact(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "" }
        return trimmed.replacingOccurrences(of: "sk-", with: "sk-***")
    }
}
