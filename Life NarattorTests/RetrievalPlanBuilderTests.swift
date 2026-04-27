import Foundation
import Testing
@testable import Life_Narattor

struct RetrievalPlanBuilderTests {
    @Test("System overview plan is not inferred from natural language")
    func systemOverviewPlanIgnoresNaturalLanguageParsing() {
        let builder = RetrievalPlanBuilder(tagLibrary: emptyTagLibrary)
        let range = RetrievalTimeRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 7 * 24 * 60 * 60),
            label: "过去 7 天"
        )

        let plan = builder.makeSystemOverviewPlan(periodLabel: "过去 7 天", range: range)

        #expect(plan.mode == .overview)
        #expect(plan.questionShape == .openReview)
        #expect(plan.primaryFilters.isEmpty)
        #expect(plan.secondaryFilters.isEmpty)
        #expect(plan.timeRange.label == "过去 7 天")
    }

    @Test("Programmatic open review plan stays overview for spaced day labels")
    func openReviewPlanStaysOverviewForSpacedDayLabels() {
        let builder = RetrievalPlanBuilder(tagLibrary: emptyTagLibrary)
        let range = RetrievalTimeRange(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 30 * 24 * 60 * 60),
            label: "过去 30 天"
        )

        let plan = builder.makeOpenReviewPlan(periodLabel: "过去 30 天", range: range)

        #expect(plan.mode == .overview)
        #expect(plan.questionShape == .openReview)
        #expect(plan.primaryFilters.isEmpty)
        #expect(plan.secondaryFilters.isEmpty)
    }

    private var emptyTagLibrary: TagLibrary {
        TagLibrary(project: [], habit: [], theme: [], person: [], goal: [], context: [])
    }
}
