import Foundation

struct SemanticChunkDraft: Codable, Hashable {
    let text: String
    let kind: String
    let sequenceIndex: Int?

    private enum CodingKeys: String, CodingKey {
        case text
        case kind
        case sequenceIndex = "sequence_index"
    }
}

struct RecordUnitAttribute: Codable, Hashable {
    let name: String
    let value: String
}

struct RecordUnitDraft: Codable {
    let summary: String
    let contextAttributes: [RecordUnitAttribute]
    let behavioralChain: [String]
    let resultOrState: [String]
    let tagHints: [String]
    let confidence: Double?
    let startChar: Int?
    let endChar: Int?

    private enum CodingKeys: String, CodingKey {
        case summary
        case contextAttributes = "context_attributes"
        case legacyAttributes = "attributes"
        case behavioralChain = "behavioral_chain"
        case resultOrState = "result_or_state"
        case tagHints = "tag_hints"
        case confidence
        case startChar = "start_char"
        case endChar = "end_char"
    }

    init(
        summary: String,
        contextAttributes: [RecordUnitAttribute],
        behavioralChain: [String],
        resultOrState: [String],
        tagHints: [String],
        confidence: Double?,
        startChar: Int?,
        endChar: Int?
    ) {
        self.summary = summary
        self.contextAttributes = contextAttributes
        self.behavioralChain = behavioralChain
        self.resultOrState = resultOrState
        self.tagHints = tagHints
        self.confidence = confidence
        self.startChar = startChar
        self.endChar = endChar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decode(String.self, forKey: .summary)
        let newAttributes = try container.decodeIfPresent([RecordUnitAttribute].self, forKey: .contextAttributes)
        let legacyAttributes = try container.decodeIfPresent([RecordUnitAttribute].self, forKey: .legacyAttributes)
        contextAttributes = newAttributes ?? legacyAttributes ?? []
        behavioralChain = try container.decodeIfPresent([String].self, forKey: .behavioralChain) ?? []
        resultOrState = try container.decodeIfPresent([String].self, forKey: .resultOrState) ?? []
        tagHints = try container.decodeIfPresent([String].self, forKey: .tagHints) ?? []
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        startChar = try container.decodeIfPresent(Int.self, forKey: .startChar)
        endChar = try container.decodeIfPresent(Int.self, forKey: .endChar)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(summary, forKey: .summary)
        try container.encode(contextAttributes, forKey: .contextAttributes)
        try container.encode(behavioralChain, forKey: .behavioralChain)
        try container.encode(resultOrState, forKey: .resultOrState)
        try container.encode(tagHints, forKey: .tagHints)
        try container.encodeIfPresent(confidence, forKey: .confidence)
        try container.encodeIfPresent(startChar, forKey: .startChar)
        try container.encodeIfPresent(endChar, forKey: .endChar)
    }

    var normalizedForDisplay: RecordUnitDraft {
        let cleanSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAttributes = contextAttributes.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let cleanChain = behavioralChain
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cleanResults = resultOrState
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { Self.isLikelyResultOrStateText($0) }
            .filter { !Self.isSemanticallyRedundant($0, comparedTo: cleanSummary) }
        let cleanTags = tagHints
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return RecordUnitDraft(
            summary: cleanSummary,
            contextAttributes: Array(NSOrderedSet(array: cleanAttributes)) as? [RecordUnitAttribute] ?? cleanAttributes,
            behavioralChain: Self.uniqued(cleanChain),
            resultOrState: Self.uniqued(cleanResults),
            tagHints: Self.uniqued(cleanTags),
            confidence: confidence,
            startChar: startChar,
            endChar: endChar
        )
    }

    var isStandaloneStateLikeUnit: Bool {
        let cleanSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSummary.isEmpty else { return false }
        guard contextAttributes.isEmpty, behavioralChain.isEmpty else { return false }
        return Self.isLikelyStateOrOutcomeText(cleanSummary)
    }

    func mergingState(into previous: RecordUnitDraft) -> RecordUnitDraft {
        let mergedResults = previous.resultOrState + [summary] + resultOrState
        let mergedTags = previous.tagHints + tagHints
        return RecordUnitDraft(
            summary: previous.summary,
            contextAttributes: previous.contextAttributes,
            behavioralChain: previous.behavioralChain,
            resultOrState: mergedResults,
            tagHints: mergedTags,
            confidence: previous.confidence ?? confidence,
            startChar: previous.startChar,
            endChar: endChar ?? previous.endChar
        ).normalizedForDisplay
    }

    private static func uniqued(_ values: [String]) -> [String] {
        Array(NSOrderedSet(array: values)) as? [String] ?? values
    }

    private static func isLikelyResultOrStateText(_ text: String) -> Bool {
        isLikelyStateOrOutcomeText(text) || text.contains("完成") || text.contains("没完成") || text.contains("加班")
    }

    private static func isLikelyStateOrOutcomeText(_ text: String) -> Bool {
        let markers = [
            "感觉", "感到", "觉得", "心情", "状态", "结果", "后果", "因此", "所以", "只能",
            "舒服", "不错", "无奈", "焦虑", "轻松", "放松", "开心", "难受", "累", "困", "生气", "烦"
        ]
        return markers.contains { text.contains($0) }
    }

    private static func isSemanticallyRedundant(_ candidate: String, comparedTo summary: String) -> Bool {
        let left = normalizedComparisonText(candidate)
        let right = normalizedComparisonText(summary)
        guard !left.isEmpty, !right.isEmpty else { return false }
        if right.contains(left) || left.contains(right) {
            return true
        }

        let overlap = Double(Set(left).intersection(Set(right)).count)
        let baseline = Double(Set(left).count)
        guard baseline > 0 else { return false }
        return overlap / baseline >= 0.6
    }

    private static func normalizedComparisonText(_ text: String) -> String {
        let stopCharacters = CharacterSet(charactersIn: " \n\t，。！？；：、“”‘’()（）[]【】,.!?;:'\"0123456789")
        let stopWords = ["我", "现在", "今天", "明天", "了", "的", "很", "非常", "大概", "左右", "一下", "一下子"]
        var normalized = text.components(separatedBy: stopCharacters).joined()
        stopWords.forEach { normalized = normalized.replacingOccurrences(of: $0, with: "") }
        return normalized
    }
}

struct AtomizationArtifactPayload: Codable {
    let semanticChunks: [SemanticChunkDraft]
    let recordUnits: [RecordUnitDraft]
    let atomizeVersion: String?

    private enum CodingKeys: String, CodingKey {
        case semanticChunks = "semantic_chunks"
        case recordUnits = "record_units"
        case atomizeVersion = "atomize_version"
    }

    init(semanticChunks: [SemanticChunkDraft], recordUnits: [RecordUnitDraft], atomizeVersion: String?) {
        self.semanticChunks = semanticChunks
        self.recordUnits = recordUnits
        self.atomizeVersion = atomizeVersion
    }

    init(result: AtomizeResult) {
        self.semanticChunks = result.semanticChunks
        self.recordUnits = result.recordUnits
        self.atomizeVersion = result.atomizeVersion
    }

    func encodedJSON() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from json: String) -> AtomizationArtifactPayload? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AtomizationArtifactPayload.self, from: data)
    }
}

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

    init(type: AtomType, content: String, confidence: Double?, startChar: Int?, endChar: Int?) {
        self.type = type
        self.content = content
        self.confidence = confidence
        self.startChar = startChar
        self.endChar = endChar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let content = try container.decode(String.self, forKey: .content)
        self.content = content
        self.confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        self.startChar = try container.decodeIfPresent(Int.self, forKey: .startChar)
        self.endChar = try container.decodeIfPresent(Int.self, forKey: .endChar)
        self.type = (try? container.decodeIfPresent(AtomType.self, forKey: .type)) ?? AtomType.inferred(from: content)
    }
}

struct AtomizeResult: Decodable {
    let semanticChunks: [SemanticChunkDraft]
    let recordUnits: [RecordUnitDraft]
    let atomizeVersion: String?

    private enum CodingKeys: String, CodingKey {
        case atoms
        case semanticChunks = "semantic_chunks"
        case recordUnits = "record_units"
        case atomizeVersion = "atomize_version"
    }

    var atoms: [AtomDraft] {
        recordUnits.map { unit in
            let content = renderedContent(for: unit)
            return AtomDraft(
                type: AtomType.inferred(from: content),
                content: content,
                confidence: unit.confidence,
                startChar: unit.startChar,
                endChar: unit.endChar
            )
        }
    }

    init(semanticChunks: [SemanticChunkDraft], recordUnits: [RecordUnitDraft], atomizeVersion: String?) {
        self.semanticChunks = semanticChunks
        self.recordUnits = recordUnits
        self.atomizeVersion = atomizeVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        atomizeVersion = try container.decodeIfPresent(String.self, forKey: .atomizeVersion)
        semanticChunks = try container.decodeIfPresent([SemanticChunkDraft].self, forKey: .semanticChunks) ?? []

        if let recordUnits = try container.decodeIfPresent([RecordUnitDraft].self, forKey: .recordUnits) {
            self.recordUnits = Self.normalizeRecordUnits(
                recordUnits.filter { !$0.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            )
            return
        }

        let legacyAtoms = try container.decodeIfPresent([AtomDraft].self, forKey: .atoms) ?? []
        self.recordUnits = Self.normalizeRecordUnits(legacyAtoms.map {
            RecordUnitDraft(
                summary: $0.content,
                contextAttributes: [],
                behavioralChain: [],
                resultOrState: [],
                tagHints: [],
                confidence: $0.confidence,
                startChar: $0.startChar,
                endChar: $0.endChar
            )
        })
    }

    var tagSuggestionDrafts: [AtomDraft] {
        recordUnits.map { unit in
            var components: [String] = [unit.summary]
            let attributeValues = unit.contextAttributes.map(\.value).filter { !$0.isEmpty }
            let chainText = unit.behavioralChain.filter { !$0.isEmpty }
            let resultText = unit.resultOrState.filter { !$0.isEmpty }
            let tagText = unit.tagHints.filter { !$0.isEmpty }
            if !attributeValues.isEmpty {
                components.append(attributeValues.joined(separator: " "))
            }
            if !chainText.isEmpty {
                components.append(chainText.joined(separator: " "))
            }
            if !resultText.isEmpty {
                components.append(resultText.joined(separator: " "))
            }
            if !tagText.isEmpty {
                components.append(tagText.joined(separator: " "))
            }
            let content = components.joined(separator: " ")
            return AtomDraft(
                type: AtomType.inferred(from: content),
                content: content,
                confidence: unit.confidence,
                startChar: unit.startChar,
                endChar: unit.endChar
            )
        }
    }

    private func renderedContent(for unit: RecordUnitDraft) -> String {
        let summary = unit.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let attributes = unit.contextAttributes.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !summary.contains($0.value)
        }
        let chain = unit.behavioralChain
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !summary.contains($0) }

        var segments: [String] = []

        if !attributes.isEmpty {
            segments.append(attributes.map { "\($0.name)：\($0.value)" }.joined(separator: "；"))
        }
        if !chain.isEmpty {
            segments.append("过程：\(chain.joined(separator: " → "))")
        }
        let result = unit.resultOrState
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !summary.contains($0) }
        if !result.isEmpty {
            segments.append("结果：\(result.joined(separator: "；"))")
        }
        guard !segments.isEmpty else { return summary }
        return "\(summary)（\(segments.joined(separator: "；"))）"
    }

    private static func normalizeRecordUnits(_ units: [RecordUnitDraft]) -> [RecordUnitDraft] {
        var merged: [RecordUnitDraft] = []

        for rawUnit in units {
            let unit = rawUnit.normalizedForDisplay
            guard !unit.summary.isEmpty else { continue }

            if unit.isStandaloneStateLikeUnit, let previous = merged.last {
                merged[merged.count - 1] = unit.mergingState(into: previous)
            } else {
                merged.append(unit)
            }
        }

        return merged
    }
}

struct TagLibrary {
    let project: [String]
    let habit: [String]
    let theme: [String]
    let person: [String]
    let goal: [String]
    let context: [String]

    var summary: [String: [String]] {
        [
            "project": project,
            "habit": habit,
            "theme": theme,
            "person": person,
            "goal": goal,
            "context": context
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

    init(suggestions: [TagSuggestion], hiddenSuggestions: [TagSuggestion]) {
        self.suggestions = suggestions
        self.hiddenSuggestions = hiddenSuggestions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        suggestions = try container.decodeIfPresent([TagSuggestion].self, forKey: .suggestions) ?? []
        hiddenSuggestions = try container.decodeIfPresent([TagSuggestion].self, forKey: .hiddenSuggestions) ?? []
    }
}
