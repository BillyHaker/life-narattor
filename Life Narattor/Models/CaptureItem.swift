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
    let assistRecord: AssistArchiveRecord?
    let atomsCount: Int
    let processingState: CaptureProcessingState
    let inputType: CaptureInputType
    let audioPath: String?
    let transcriptText: String?
    let transcriptionStatus: TranscriptionStatus?
    var transcriptionErrorReason: String? = nil
    let atomizationErrorReason: String?
    let isTranscriptionActive: Bool
    let sourceThreadID: UUID?
    let revisionCount: Int

    init(
        id: UUID,
        createdAt: Date,
        rawText: String,
        cleanText: String?,
        ackTitle: String?,
        ackDetail: String?,
        dayPart: DayPart,
        mode: CaptureInputMode,
        assistRecord: AssistArchiveRecord?,
        atomsCount: Int,
        processingState: CaptureProcessingState,
        inputType: CaptureInputType,
        audioPath: String?,
        transcriptText: String?,
        transcriptionStatus: TranscriptionStatus?,
        transcriptionErrorReason: String? = nil,
        atomizationErrorReason: String? = nil,
        isTranscriptionActive: Bool = false,
        sourceThreadID: UUID? = nil,
        revisionCount: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.rawText = rawText
        self.cleanText = cleanText
        self.ackTitle = ackTitle
        self.ackDetail = ackDetail
        self.dayPart = dayPart
        self.mode = mode
        self.assistRecord = assistRecord
        self.atomsCount = atomsCount
        self.processingState = processingState
        self.inputType = inputType
        self.audioPath = audioPath
        self.transcriptText = transcriptText
        self.transcriptionStatus = transcriptionStatus
        self.transcriptionErrorReason = transcriptionErrorReason
        self.atomizationErrorReason = atomizationErrorReason
        self.isTranscriptionActive = isTranscriptionActive
        self.sourceThreadID = sourceThreadID
        self.revisionCount = revisionCount
    }
}

enum CaptureProcessingState: String, CaseIterable, Identifiable, Codable {
    case pendingClean
    case cleanReady
    case pendingSplit
    case splitting
    case atomsReady
    case tagsSuggested
    case splitFailed

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .pendingClean:
            return "整理中…"
        case .cleanReady:
            return "已去停顿"
        case .pendingSplit:
            return "等待拆分"
        case .splitting:
            return "拆分中…"
        case .atomsReady:
            return "已拆分"
        case .tagsSuggested:
            return "已标注"
        case .splitFailed:
            return "拆分失败"
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
