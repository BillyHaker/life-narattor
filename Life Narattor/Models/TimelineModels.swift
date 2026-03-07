import Foundation

struct TimelineDay: Identifiable {
    let id: UUID
    let date: Date
    let highlights: [String]
    let hasNarrative: Bool
}

enum TimelineScope: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "今天"
        case .week:
            return "本周"
        case .month:
            return "本月"
        case .custom:
            return "自定义"
        }
    }
}
