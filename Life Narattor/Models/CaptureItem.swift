import Foundation

struct CaptureItem: Identifiable {
    let id: UUID
    let createdAt: Date
    let rawText: String
    let cleanText: String?
    let ackTitle: String?
    let ackDetail: String?
    let dayPart: DayPart
    let mode: CaptureInputMode
    let assistPayload: AssistArchivePayload?
    let atomsCount: Int
    let processingState: CaptureProcessingState
}

enum CaptureProcessingState: String, CaseIterable, Identifiable, Codable {
    case pendingClean
    case cleanReady
    case atomsReady
    case tagsSuggested

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .pendingClean:
            return "整理中…"
        case .cleanReady:
            return "已去停顿"
        case .atomsReady:
            return "已拆分"
        case .tagsSuggested:
            return "已标注"
        }
    }
}

enum CaptureInputMode: String, CaseIterable, Identifiable, Codable {
    case log
    case assist

    var id: String { rawValue }

    var title: String {
        switch self {
        case .log:
            return "记录"
        case .assist:
            return "助手"
        }
    }
}

enum DayPart: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning:
            return "上午"
        case .afternoon:
            return "下午"
        case .evening:
            return "晚上"
        }
    }
}
