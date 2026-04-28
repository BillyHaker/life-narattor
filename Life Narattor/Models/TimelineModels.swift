import Foundation

struct TimelineDay: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let recordCount: Int
    let dayParts: [DayPart]
    let primaryLine: String
    let secondaryLines: [String]
    let highlightCaptureIDs: [UUID]
    let hasGeneratedNarrative: Bool
}

enum TimelineScope: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case custom

    var id: String { rawValue }

    static var timelineTabs: [TimelineScope] {
        [.today, .week, .month]
    }

    var title: String {
        switch self {
        case .today:
            return "昨日"
        case .week:
            return "7天回顾"
        case .month:
            return "30天回顾"
        case .custom:
            return "近30天"
        }
    }
}
