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
    let tagSuggestions: [AssistTagSuggestion]
    let confidence: String
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
