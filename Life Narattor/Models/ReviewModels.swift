import Foundation

enum ReviewPeriod: String, CaseIterable, Identifiable {
    case weekly
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly:
            return "7 天回顾"
        case .monthly:
            return "30 天回顾"
        }
    }
}

struct ReviewSnippet: Identifiable {
    let id: UUID
    let title: String
    let detail: String
}

enum TimelineReviewSnapshotKind: String, CaseIterable, Codable, Identifiable {
    case yesterday
    case last7Days
    case last30Days

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yesterday:
            return "昨日故事线"
        case .last7Days:
            return "过去 7 天故事线"
        case .last30Days:
            return "过去 30 天故事线"
        }
    }

    var artifactKey: String {
        "timeline_review_snapshot.\(rawValue)"
    }

    var artifactSourceID: UUID {
        switch self {
        case .yesterday:
            return UUID(uuidString: "7C92E7AA-B4B8-4B07-BC28-4023177F6751")!
        case .last7Days:
            return UUID(uuidString: "D9F45F9C-0F0D-47A3-9754-5A13A899FBE2")!
        case .last30Days:
            return UUID(uuidString: "1F824182-B150-48D3-A530-0C028A013863")!
        }
    }
}

struct TimelineReviewSnapshotPayload: Codable {
    let kind: TimelineReviewSnapshotKind
    let generatedAt: Date
    let rangeStart: Date
    let rangeEnd: Date
    let summaryText: String
    let activeDayCount: Int
    let totalRecordCount: Int
    let overviewSignals: [String]
    let latestRecordAt: Date?
    let isEmpty: Bool
}
