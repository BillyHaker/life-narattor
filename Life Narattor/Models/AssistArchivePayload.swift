import Foundation

struct AssistArchivePayload: Codable {
    let reply: String
    let card: AssistArchiveCard
    let turnPolicy: AssistTurnPolicy

    func encodedJSON() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from json: String) -> AssistArchivePayload? {
        guard let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(AssistArchivePayload.self, from: data)
    }
}

struct AssistArchiveCard: Codable {
    let title: String
    let context: String
    let keyPoints: [String]
    let nextSteps: [String]
    let recordUnits: [AssistRecordUnit]
    let tagSuggestions: [AssistTagSuggestion]
    let confidence: String

    init(
        title: String,
        context: String,
        keyPoints: [String],
        nextSteps: [String],
        recordUnits: [AssistRecordUnit] = [],
        tagSuggestions: [AssistTagSuggestion],
        confidence: String
    ) {
        self.title = title
        self.context = context
        self.keyPoints = keyPoints
        self.nextSteps = nextSteps
        self.recordUnits = recordUnits
        self.tagSuggestions = tagSuggestions
        self.confidence = confidence
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case context
        case keyPoints
        case nextSteps
        case recordUnits
        case tagSuggestions
        case confidence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        context = try container.decode(String.self, forKey: .context)
        keyPoints = try container.decode([String].self, forKey: .keyPoints)
        nextSteps = try container.decode([String].self, forKey: .nextSteps)
        recordUnits = try container.decodeIfPresent([AssistRecordUnit].self, forKey: .recordUnits) ?? []
        tagSuggestions = try container.decodeIfPresent([AssistTagSuggestion].self, forKey: .tagSuggestions) ?? []
        confidence = try container.decodeIfPresent(String.self, forKey: .confidence) ?? "medium"
    }

    var effectiveRecordUnits: [AssistRecordUnit] {
        let cleanedUnits = recordUnits.compactMap { $0.normalizedOrNil }
        if !cleanedUnits.isEmpty {
            return cleanedUnits
        }

        let fallbackSummary = context.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackUnit = AssistRecordUnit(
            title: title,
            summary: fallbackSummary.isEmpty ? keyPoints.joined(separator: "；") : fallbackSummary,
            keyPoints: keyPoints,
            nextSteps: nextSteps
        )
        return fallbackUnit.normalizedOrNil.map { [$0] } ?? []
    }
}

struct AssistRecordUnit: Codable, Hashable {
    let title: String
    let summary: String
    let keyPoints: [String]
    let nextSteps: [String]

    init(title: String, summary: String, keyPoints: [String], nextSteps: [String]) {
        self.title = title
        self.summary = summary
        self.keyPoints = keyPoints
        self.nextSteps = nextSteps
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case summary
        case keyPoints
        case nextSteps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        keyPoints = try container.decodeIfPresent([String].self, forKey: .keyPoints) ?? []
        nextSteps = try container.decodeIfPresent([String].self, forKey: .nextSteps) ?? []
    }

    var normalizedOrNil: AssistRecordUnit? {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPoints = keyPoints
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cleanedSteps = nextSteps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleanedTitle.isEmpty || !cleanedSummary.isEmpty || !cleanedPoints.isEmpty || !cleanedSteps.isEmpty else {
            return nil
        }

        return AssistRecordUnit(
            title: cleanedTitle.isEmpty ? "分化记录" : cleanedTitle,
            summary: cleanedSummary,
            keyPoints: cleanedPoints,
            nextSteps: cleanedSteps
        )
    }
}

struct AssistTagSuggestion: Codable {
    let tagType: String
    let name: String
    let score: Double?
}

struct AssistTurnPolicy: Codable {
    let usedClarification: Bool
    let turnsRemaining: Int
}

struct AssistArchiveRecord {
    let payload: AssistArchivePayload
    let status: AssistArchiveStatus
}

enum AssistArchiveStatus: String {
    case draft
    case saved
    case ended
}
