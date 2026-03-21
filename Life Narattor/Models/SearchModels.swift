import Foundation

enum SearchResultSource {
    case capture(CaptureItem)
    case atom(AtomItem)
}

struct SearchResultItem: Identifiable {
    let id: UUID
    let date: Date
    let timeText: String
    let snippet: String
    let tags: [String]
    let hitReason: String?
    let source: SearchResultSource
}

enum SearchFilterType: String, CaseIterable, Identifiable {
    case project
    case habit
    case theme
    case person
    case goal
    case context
    case dateRange

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
        case .dateRange:
            return "日期范围"
        }
    }
}

extension SearchFilterType {
    static func from(tagType: TagType) -> SearchFilterType? {
        switch tagType {
        case .project:
            return .project
        case .habit:
            return .habit
        case .theme:
            return .theme
        case .person:
            return .person
        case .goal:
            return .goal
        case .context:
            return .context
        }
    }

    var tagType: TagType? {
        switch self {
        case .project:
            return .project
        case .habit:
            return .habit
        case .theme:
            return .theme
        case .person:
            return .person
        case .goal:
            return .goal
        case .context:
            return .context
        case .dateRange:
            return nil
        }
    }
}
