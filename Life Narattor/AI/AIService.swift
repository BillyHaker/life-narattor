import Foundation

protocol AIService {
    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult
    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload
    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle
}

struct QuickAckResult {
    let ackTitle: String
    let ackDetail: String
}

struct DeepTaskRequest {
    let taskType: DeepTaskType
    let scopeKey: String
    let inputs: [String: String]
}

enum DeepTaskType: String {
    case projectReview
    case weeklyReview
    case themeReview
    case deepDailyReview
}

struct DeepTaskHandle {
    let id: String
}

final class MockAIService: AIService {
    func quickAck(for capture: CaptureItem) async throws -> QuickAckResult {
        let title = "✅ 已记下"
        let detail = "确认：\(capture.cleanText ?? capture.rawText)"
        return QuickAckResult(ackTitle: title, ackDetail: detail)
    }

    func assistArchive(for capture: CaptureItem, questionText: String) async throws -> AssistArchivePayload {
        let card = AssistArchiveCard(
            title: "记录卡片：\(questionText.prefix(12))",
            context: "来自一次简短的整理请求。",
            keyPoints: ["整理了问题的关键点", "保留了原始表达"],
            nextSteps: ["需要时再补充细节"],
            tagSuggestions: [AssistTagSuggestion(tagType: "theme", name: "Assist")],
            confidence: "medium"
        )
        return AssistArchivePayload(
            reply: "我明白了，这是一个可以存档的记录。",
            card: card,
            turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 1)
        )
    }

    func createDeepTask(_ request: DeepTaskRequest) async throws -> DeepTaskHandle {
        return DeepTaskHandle(id: "mock-task-\(UUID().uuidString)")
    }
}
