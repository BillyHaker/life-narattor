import Foundation

struct ProjectItem: Identifiable {
    let id: UUID
    let name: String
    let summary: String
    let updatedAt: Date
}

enum ProjectDetailTab: String, CaseIterable, Identifiable {
    case timeline
    case review

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timeline:
            return "时间线"
        case .review:
            return "回顾"
        }
    }
}
