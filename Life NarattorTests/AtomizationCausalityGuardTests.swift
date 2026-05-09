import Testing
@testable import Life_Narattor

struct AtomizationCausalityGuardTests {
    @Test("removes inferred definite causality when source is only adjacent facts")
    func removesInferredDefiniteCausality() {
        let result = makeResult(summary: "因为昨天睡得晚，今天醒来嗓子疼")

        let sanitized = AtomizationCausalityGuard.sanitize(
            result,
            sourceText: "昨天睡得晚，今天醒来嗓子疼。"
        )

        #expect(sanitized.recordUnits.first?.summary == "昨天睡得晚，今天醒来嗓子疼")
    }

    @Test("keeps explicit causality from source text")
    func keepsExplicitCausality() {
        let result = makeResult(summary: "因为昨天睡得晚，所以今天很困")

        let sanitized = AtomizationCausalityGuard.sanitize(
            result,
            sourceText: "因为昨天睡得晚，所以今天很困。"
        )

        #expect(sanitized.recordUnits.first?.summary == "因为昨天睡得晚，所以今天很困")
    }

    @Test("does not turn co-occurring pressure and appetite into causality")
    func avoidsPressureAppetiteCausality() {
        let result = makeResult(summary: "压力很大导致胃口不好")

        let sanitized = AtomizationCausalityGuard.sanitize(
            result,
            sourceText: "最近压力很大，胃口也不好。"
        )

        #expect(sanitized.recordUnits.first?.summary == "压力很大；胃口不好")
    }

    @Test("leaves parallel contrast facts unchanged")
    func leavesParallelContrastFactsUnchanged() {
        let result = makeResult(summary: "今天外界冷，火车上却挺热")

        let sanitized = AtomizationCausalityGuard.sanitize(
            result,
            sourceText: "今天外界冷，火车上却挺热。"
        )

        #expect(sanitized.recordUnits.first?.summary == "今天外界冷，火车上却挺热")
    }
}

private extension AtomizationCausalityGuardTests {
    func makeResult(summary: String) -> AtomizeResult {
        AtomizeResult(
            semanticChunks: [
                SemanticChunkDraft(text: summary, kind: "event", sequenceIndex: 0)
            ],
            recordUnits: [
                RecordUnitDraft(
                    summary: summary,
                    contextAttributes: [],
                    behavioralChain: [],
                    resultOrState: [],
                    tagHints: [],
                    confidence: 0.8,
                    startChar: nil,
                    endChar: nil
                )
            ],
            atomizeVersion: "test_v1"
        )
    }
}
