import Foundation

enum CaptureInputType: String, CaseIterable, Identifiable, Codable {
    case text
    case voice

    var id: String { rawValue }
}

enum TranscriptionStatus: String, CaseIterable, Identifiable, Codable {
    case pending
    case completed
    case failed
    case offline

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .pending:
            return "正在转写…"
        case .completed:
            return "记录成功"
        case .failed:
            return "转写失败 · 重试"
        case .offline:
            return "离线中 · 稍后自动转写"
        }
    }
}
