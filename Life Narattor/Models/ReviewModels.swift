import Foundation

enum ReviewPeriod: String, CaseIterable, Identifiable {
    case weekly
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly:
            return "本周回顾"
        case .monthly:
            return "本月回顾"
        }
    }
}

struct ReviewSnippet: Identifiable {
    let id: UUID
    let title: String
    let detail: String
}
