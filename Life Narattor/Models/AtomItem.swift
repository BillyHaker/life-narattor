import Foundation

struct AtomItem: Identifiable {
    let id: UUID
    let captureID: UUID
    let type: AtomType
    let content: String
    let orderInCapture: Int
    let isKey: Bool
    let tags: [TagItem]
    let startChar: Int? // nil if offset not available
    let endChar: Int? // nil if offset not available
    let atomizeVersion: String? // e.g. "atom_v1"
}

enum AtomType: String, CaseIterable, Identifiable, Codable {
    case event
    case feeling
    case thought
    case action
    case decision
    case insight
    case question
    case context

    var id: String { rawValue }

    var title: String {
        switch self {
        case .event:
            return "事件"
        case .feeling:
            return "感受"
        case .thought:
            return "想法"
        case .action:
            return "行动"
        case .decision:
            return "决定"
        case .insight:
            return "洞察"
        case .question:
            return "问题"
        case .context:
            return "背景"
        }
    }

    var iconName: String {
        switch self {
        case .event:
            return "bolt.fill"
        case .feeling:
            return "heart.fill"
        case .thought:
            return "brain.head.profile"
        case .action:
            return "figure.walk"
        case .decision:
            return "checkmark.seal.fill"
        case .insight:
            return "sparkles"
        case .question:
            return "questionmark.circle.fill"
        case .context:
            return "text.alignleft"
        }
    }

    static func inferred(from content: String) -> AtomType {
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return .event }

        if text.contains("?") || text.contains("？") ||
            ["要不要", "是否", "怎么", "为什么", "是不是"].contains(where: text.contains) {
            return .question
        }
        if ["决定", "打算", "只能", "确定", "准备"].contains(where: text.contains) {
            return .decision
        }
        if ["感觉", "觉得", "烦", "开心", "舒服", "焦虑", "难受", "紧张", "害怕", "喜欢"].contains(where: text.contains) {
            return .feeling
        }
        if ["可能", "其实", "应该", "好像", "意识到", "发现", "明白了"].contains(where: text.contains) {
            return .thought
        }
        if ["要去", "开始", "去", "做", "执行", "安排", "处理", "上班", "开会"].contains(where: text.contains) {
            return .action
        }
        return .event
    }
}

struct TagItem: Identifiable {
    let id: UUID
    let name: String
    let type: TagType
    let isCommon: Bool
    let isSuggested: Bool
    let isUserVisible: Bool

    var suggestionBadgeText: String? {
        guard isSuggested else { return nil }
        return isUserVisible ? "推荐" : "新建议"
    }
}

enum TagType: String, CaseIterable, Identifiable, Codable {
    case project
    case habit
    case theme
    case person
    case goal
    case context

    var id: String { rawValue }

    var title: String {
        switch self {
        case .project:
            return "项目"
        case .habit:
            return "习惯"
        case .theme:
            return "主题"
        case .person:
            return "人物"
        case .goal:
            return "目标"
        case .context:
            return "场景"
        }
    }
}
