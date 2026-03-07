import Foundation

struct AtomItem: Identifiable {
    let id: UUID
    let captureID: UUID
    let type: AtomType
    let content: String
    let orderInCapture: Int
    let isKey: Bool
    let tags: [TagItem]
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
}

struct TagItem: Identifiable {
    let id: UUID
    let name: String
    let type: TagType
    let isCommon: Bool
}

enum TagType: String, CaseIterable, Identifiable, Codable {
    case project
    case theme
    case person
    case goal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .project:
            return "项目"
        case .theme:
            return "主题"
        case .person:
            return "人物"
        case .goal:
            return "目标"
        }
    }
}
