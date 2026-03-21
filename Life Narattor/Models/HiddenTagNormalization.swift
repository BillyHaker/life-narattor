import Foundation

let hiddenTagNormalizationArtifactType = "hidden_tag_normalization_map"
let hiddenTagNormalizationSourceID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

enum HiddenTagBucket: String, Codable, CaseIterable {
    case workProject = "work_project"
    case habitRhythm = "habit_rhythm"
    case stateEmotion = "state_emotion"
    case bodyHealth = "body_health"
    case contextScene = "context_scene"
    case personRelation = "person_relation"
    case interestTopic = "interest_topic"
    case misc = "misc"

    var title: String {
        switch self {
        case .workProject: return "工作 / 项目"
        case .habitRhythm: return "习惯 / 节奏"
        case .stateEmotion: return "状态 / 情绪"
        case .bodyHealth: return "身体 / 健康"
        case .contextScene: return "场景 / 时间"
        case .personRelation: return "人物 / 关系"
        case .interestTopic: return "兴趣 / 主题"
        case .misc: return "其他"
        }
    }
}

struct HiddenTagInventoryItem: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let type: String
    let linkCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case linkCount = "link_count"
    }
}

struct HiddenTagClusterGroup: Codable, Hashable, Identifiable {
    let bucket: HiddenTagBucket
    let title: String
    let memberIDs: [UUID]

    var id: String {
        "\(bucket.rawValue):\(memberIDs.map(\.uuidString).joined(separator: ","))"
    }

    private enum CodingKeys: String, CodingKey {
        case bucket
        case title
        case memberIDs = "member_ids"
    }
}

struct HiddenTagClusterResult: Codable {
    let groups: [HiddenTagClusterGroup]
}

struct HiddenTagCanonicalMapping: Codable, Hashable, Identifiable {
    let rawTagID: UUID
    let rawName: String
    let rawType: String
    let bucket: HiddenTagBucket
    let canonicalName: String
    let confidence: Double?
    let reason: String?

    var id: UUID { rawTagID }

    private enum CodingKeys: String, CodingKey {
        case rawTagID = "raw_tag_id"
        case rawName = "raw_name"
        case rawType = "raw_type"
        case bucket
        case canonicalName = "canonical_name"
        case confidence
        case reason
    }
}

struct HiddenTagNormalizationMap: Codable {
    let updatedAt: Date
    let mappings: [HiddenTagCanonicalMapping]

    private enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case mappings
    }

    init(updatedAt: Date, mappings: [HiddenTagCanonicalMapping]) {
        self.updatedAt = updatedAt
        self.mappings = mappings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mappings = try container.decode([HiddenTagCanonicalMapping].self, forKey: .mappings)

        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .updatedAt) {
            updatedAt = Date(timeIntervalSince1970: timestamp)
        } else if let rawString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
                  let date = ISO8601DateFormatter().date(from: rawString) {
            updatedAt = date
        } else {
            updatedAt = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ISO8601DateFormatter().string(from: updatedAt), forKey: .updatedAt)
        try container.encode(mappings, forKey: .mappings)
    }

    func canonicalName(for rawTagID: UUID) -> String? {
        mappings.first(where: { $0.rawTagID == rawTagID })?.canonicalName
    }
}
