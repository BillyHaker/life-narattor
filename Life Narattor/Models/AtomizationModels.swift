import Foundation

struct AtomDraft: Codable {
    let type: AtomType
    let content: String
    let confidence: Double?
    let startChar: Int?
    let endChar: Int?

    private enum CodingKeys: String, CodingKey {
        case type
        case content
        case confidence
        case startChar = "start_char"
        case endChar = "end_char"
    }
}

struct AtomizeResult: Codable {
    let atoms: [AtomDraft]
    let atomizeVersion: String?

    private enum CodingKeys: String, CodingKey {
        case atoms
        case atomizeVersion = "atomize_version"
    }
}

struct TagLibrary {
    let project: [String]
    let theme: [String]
    let person: [String]
    let goal: [String]

    var summary: [String: [String]] {
        [
            "project": project,
            "theme": theme,
            "person": person,
            "goal": goal
        ]
    }
}

struct TagSuggestion: Codable {
    let tagType: String
    let name: String
    let score: Double?

    private enum CodingKeys: String, CodingKey {
        case tagType = "tag_type"
        case name
        case score
    }
}

struct TagSuggestionResult: Codable {
    let suggestions: [TagSuggestion]
    let hiddenSuggestions: [TagSuggestion]

    private enum CodingKeys: String, CodingKey {
        case suggestions
        case hiddenSuggestions = "hidden_suggestions"
    }
}
