import Foundation

struct SearchResultItem: Identifiable {
    let id: UUID
    let date: Date
    let timeText: String
    let snippet: String
    let tags: [String]
}

enum SearchFilterType: String, CaseIterable, Identifiable {
    case project
    case theme
    case person
    case dateRange

    var id: String { rawValue }

    var title: String {
        switch self {
        case .project:
            return "项目"
        case .theme:
            return "主题"
        case .person:
            return "人物"
        case .dateRange:
            return "日期范围"
        }
    }
}
