import Foundation

enum RetrievalMode: String, Codable {
    case overview
    case focused
}

enum ReviewQuestionShape: String, Codable {
    case openReview
    case projectReview
    case themeReview
    case patternReview
    case personReview
    case contextReview
    case comparison
    case relation
}

struct RetrievalTimeRange: Codable {
    let start: Date
    let end: Date
    let label: String
}

struct RetrievalTagFilter: Codable, Hashable {
    let type: TagType
    let name: String
    let strength: Double
    let source: RetrievalTagSource
}

enum RetrievalTagSource: String, Codable {
    case explicit
    case hidden
    case hint
    case inferred
}

struct RetrievalTagScopeWeights: Codable {
    let project: Double
    let habit: Double
    let theme: Double
    let person: Double
    let goal: Double
    let context: Double
}

struct RetrievalRankingWeights: Codable {
    let primaryTagMatch: Double
    let secondaryTagMatch: Double
    let hiddenTagMatch: Double
    let hintMatch: Double
    let recency: Double
    let novelty: Double
    let repetition: Double
    let stateChange: Double
    let turningPoint: Double
}

struct RetrievalCompressionPolicy: Codable {
    let maxCaptures: Int
    let maxUnitsPerTheme: Int
    let preferCoverage: Bool
    let preferEvidenceDensity: Bool
    let preferTurningPoints: Bool
}

struct RetrievalPlan: Codable {
    let mode: RetrievalMode
    let questionShape: ReviewQuestionShape
    let query: String
    let timeRange: RetrievalTimeRange
    let focusAnchor: String?
    let relationAnchors: [String]
    let primaryFilters: [RetrievalTagFilter]
    let secondaryFilters: [RetrievalTagFilter]
    let tagScopeWeights: RetrievalTagScopeWeights
    let rankingWeights: RetrievalRankingWeights
    let compressionPolicy: RetrievalCompressionPolicy
}

struct NarrativeBriefUnit: Identifiable, Codable {
    let id: UUID
    let captureID: UUID
    let createdAt: Date
    let summary: String
    let contextAttributes: [RecordUnitAttribute]
    let behavioralChain: [String]
    let resultOrState: [String]
    let visibleTags: [String]
    let hiddenTags: [String]
    let tagHints: [String]
    let score: Double
}

struct NarrativeBrief: Codable {
    let plan: RetrievalPlan
    let generatedAt: Date
    let units: [NarrativeBriefUnit]
    let topVisibleTags: [String]
    let topHiddenTags: [String]
    let overviewPoints: [String]
}

struct NarrativeMaterialSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let bullets: [String]
}

struct NarrativeMaterial: Codable {
    let plan: RetrievalPlan
    let generatedAt: Date
    let primaryThemes: [String]
    let changeSignals: [String]
    let repeatedPatterns: [String]
    let turningPoints: [String]
    let representativeUnits: [NarrativeBriefUnit]
    let sections: [NarrativeMaterialSection]
}

struct FocusedEvidenceGroup: Identifiable, Codable {
    let id: UUID
    let title: String
    let rationale: String
    let units: [NarrativeBriefUnit]
}

struct FocusedEvidenceBundle: Codable {
    let plan: RetrievalPlan
    let generatedAt: Date
    let leadingQuestion: String
    let topSignals: [String]
    let comparisonWindows: [String]
    let evidenceGroups: [FocusedEvidenceGroup]
}

extension RetrievalTagScopeWeights {
    static let overviewDefault = RetrievalTagScopeWeights(
        project: 0.8,
        habit: 1.0,
        theme: 1.0,
        person: 0.8,
        goal: 0.9,
        context: 0.7
    )

    static let focusedDefault = RetrievalTagScopeWeights(
        project: 1.0,
        habit: 1.0,
        theme: 1.0,
        person: 1.0,
        goal: 1.0,
        context: 0.8
    )
}

extension RetrievalRankingWeights {
    static let overviewDefault = RetrievalRankingWeights(
        primaryTagMatch: 1.2,
        secondaryTagMatch: 0.7,
        hiddenTagMatch: 0.6,
        hintMatch: 0.6,
        recency: 0.5,
        novelty: 1.0,
        repetition: 0.9,
        stateChange: 0.8,
        turningPoint: 1.0
    )

    static let focusedDefault = RetrievalRankingWeights(
        primaryTagMatch: 1.5,
        secondaryTagMatch: 0.9,
        hiddenTagMatch: 0.8,
        hintMatch: 0.8,
        recency: 0.4,
        novelty: 0.5,
        repetition: 0.6,
        stateChange: 1.0,
        turningPoint: 0.8
    )
}
