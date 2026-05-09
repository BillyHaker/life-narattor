import Foundation

enum AtomizationCausalityGuard {
    private static let explicitCausalMarkers = [
        "因为", "所以", "导致", "造成", "引发", "使得", "因此", "由于", "因而", "从而",
        "可能是", "也许是", "大概是", "让我", "令我", "影响", "带来", "结果"
    ]

    private static let strongCausalMarkers = [
        "因为", "所以", "导致", "造成", "引发", "使得", "因此", "由于", "因而", "从而",
        "therefore", "because", "caused", "causes", "led to", "leads to"
    ]

    static func sanitize(_ result: AtomizeResult, sourceText: String) -> AtomizeResult {
        guard !sourceHasExplicitCausality(sourceText) else { return result }

        let chunks = result.semanticChunks.map {
            SemanticChunkDraft(
                text: sanitizeText($0.text, sourceText: sourceText),
                kind: $0.kind,
                sequenceIndex: $0.sequenceIndex
            )
        }

        let units = result.recordUnits.map { unit in
            RecordUnitDraft(
                summary: sanitizeText(unit.summary, sourceText: sourceText),
                contextAttributes: unit.contextAttributes.map {
                    RecordUnitAttribute(name: $0.name, value: sanitizeText($0.value, sourceText: sourceText))
                },
                behavioralChain: unit.behavioralChain.map { sanitizeText($0, sourceText: sourceText) },
                resultOrState: unit.resultOrState.map { sanitizeText($0, sourceText: sourceText) },
                tagHints: unit.tagHints,
                confidence: unit.confidence,
                startChar: unit.startChar,
                endChar: unit.endChar
            )
        }

        return AtomizeResult(
            semanticChunks: chunks,
            recordUnits: units,
            atomizeVersion: result.atomizeVersion
        )
    }

    static func sanitizeText(_ text: String, sourceText: String) -> String {
        guard !sourceHasExplicitCausality(sourceText), containsStrongCausality(text) else {
            return text
        }

        var sanitized = text
        [
            ("因为", ""),
            ("所以", ""),
            ("因此", ""),
            ("由于", ""),
            ("因而", ""),
            ("从而", ""),
            ("导致", "；"),
            ("造成", "；"),
            ("引发", "；"),
            ("使得", "；")
        ].forEach { target, replacement in
            sanitized = sanitized.replacingOccurrences(of: target, with: replacement)
        }

        return normalizeSeparators(sanitized)
    }

    private static func sourceHasExplicitCausality(_ text: String) -> Bool {
        explicitCausalMarkers.contains { text.localizedCaseInsensitiveContains($0) }
    }

    private static func containsStrongCausality(_ text: String) -> Bool {
        strongCausalMarkers.contains { text.localizedCaseInsensitiveContains($0) }
    }

    private static func normalizeSeparators(_ text: String) -> String {
        var normalized = text
            .replacingOccurrences(of: "，；", with: "；")
            .replacingOccurrences(of: "。；", with: "；")
            .replacingOccurrences(of: "；，", with: "；")
            .replacingOccurrences(of: "；。", with: "。")
            .replacingOccurrences(of: "；；", with: "；")
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        while normalized.contains("  ") {
            normalized = normalized.replacingOccurrences(of: "  ", with: " ")
        }

        return normalized
    }
}
