import Foundation
import Combine

final class AIDebugStore: ObservableObject {
    static let shared = AIDebugStore()

    private let maxEntries = 100
    @Published private(set) var entries: [AIDebugEntry] = []

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

        var redacted = trimmed

        // P0: Redact OpenAI API keys (sk-... or sk-proj-...)
        redacted = redacted.replacingOccurrences(
            of: "sk-[a-zA-Z0-9\\-]{20,}",
            with: "sk-***REDACTED***",
            options: .regularExpression
        )

        // P0: Redact Bearer tokens in Authorization headers
        redacted = redacted.replacingOccurrences(
            of: "Bearer [a-zA-Z0-9\\-_\\.]{20,}",
            with: "Bearer ***REDACTED***",
            options: .regularExpression
        )

        // P0: Redact API keys in JSON fields
        redacted = redacted.replacingOccurrences(
            of: "\"api_key\"\\s*:\\s*\"[^\"]+\"",
            with: "\"api_key\":\"***REDACTED***\"",
            options: .regularExpression
        )

        // P1: Redact email addresses
        redacted = redacted.replacingOccurrences(
            of: "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
            with: "***@***.***",
            options: .regularExpression
        )

        // P2: Truncate long user content (keep first 100 chars for debugging)
        if let cleanTextRange = redacted.range(of: "\"clean_text\"\\s*:\\s*\"", options: .regularExpression) {
            let start = cleanTextRange.upperBound
            if let endQuote = redacted[start...].firstIndex(of: "\"") {
                let content = redacted[start..<endQuote]
                if content.count > 100 {
                    let truncated = String(content.prefix(100)) + "...[TRUNCATED \(content.count - 100) chars]"
                    redacted.replaceSubrange(start..<endQuote, with: truncated)
                }
            }
        }

        return redacted
    }
}
