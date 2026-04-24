import Foundation
import Testing
@testable import Life_Narattor

struct AIDebugRedactorTests {
    @Test("Redacts sk-prefixed API keys")
    func redactsSKPrefixedKeys() {
        let input = "Authorization: sk-abc123XYZ456789abcdef"
        let result = AIDebugRedactor.redact(input)

        #expect(!result.contains("sk-abc123XYZ456789abcdef"))
        #expect(result.contains("sk-***REDACTED***"))
    }

    @Test("Redacts Bearer tokens")
    func redactsBearerTokens() {
        let input = "Authorization: Bearer abcdefghijklmnopqrstuvwxyz0123456789"
        let result = AIDebugRedactor.redact(input)

        #expect(!result.contains("abcdefghijklmnopqrstuvwxyz0123456789"))
        #expect(result.contains("Bearer ***REDACTED***"))
    }

    @Test("Redacts api_key JSON field")
    func redactsAPIKeyField() {
        let input = #"{"api_key": "my-super-secret-key"}"#
        let result = AIDebugRedactor.redact(input)

        #expect(!result.contains("my-super-secret-key"))
        #expect(result.contains(#""api_key":"***REDACTED***""#))
    }

    @Test("Redacts email addresses")
    func redactsEmailAddress() {
        let input = "Contact user@example.com for support."
        let result = AIDebugRedactor.redact(input)

        #expect(!result.contains("user@example.com"))
        #expect(result.contains("***@***.***"))
    }

    @Test("Truncates long clean_text payload")
    func truncatesLongCleanText() {
        let longText = String(repeating: "A", count: 150)
        let input = #"{"clean_text":"\#(longText)"}"#
        let result = AIDebugRedactor.redact(input)

        #expect(!result.contains(longText))
        #expect(result.contains("[TRUNCATED 50 chars]"))
    }
}
