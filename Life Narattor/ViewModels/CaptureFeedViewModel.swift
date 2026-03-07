import CoreData
import Foundation
import Observation

@MainActor
@Observable
final class CaptureFeedViewModel {
    var captures: [CaptureItem] = []
    var inputText: String = ""
    var inputMode: CaptureInputMode = .log

    private let context: NSManagedObjectContext
    private let aiService: AIService
    private let calendar = Calendar.current

    init(context: NSManagedObjectContext, aiService: AIService) {
        self.context = context
        self.aiService = aiService
    }

    func loadCaptures() {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            let artifactMap = loadArtifacts(for: results.map { $0.id })

            captures = results.map { entity in
                makeCaptureItem(from: entity, assistPayload: artifactMap[entity.id])
            }
        } catch {
            captures = []
        }
    }

    func addCaptureFromInput() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let entity = CaptureEntity(context: context)
        let createdAt = Date()
        let part = dayPart(for: createdAt, fallback: nil)

        entity.id = UUID()
        entity.createdAt = createdAt
        entity.rawText = trimmed
        entity.cleanText = trimmed
        entity.dayPart = part.rawValue
        entity.mode = inputMode.rawValue
        entity.processingState = CaptureProcessingState.pendingClean.rawValue
        entity.atomsCount = 0

        inputText = ""
        saveContext()
        loadCaptures()

        Task {
            switch inputMode {
            case .log:
                await updateQuickAck(for: entity)
            case .assist:
                await updateAssistArchive(for: entity, questionText: trimmed)
            }
        }
    }

    func makeDetailItem(for id: UUID) -> CaptureItem? {
        captures.first { $0.id == id }
    }

    private func updateQuickAck(for entity: CaptureEntity) async {
        let item = makeCaptureItem(from: entity, assistPayload: nil)

        do {
            let result = try await aiService.quickAck(for: item)
            entity.ackTitle = result.ackTitle
            entity.ackDetail = result.ackDetail
            entity.processingState = CaptureProcessingState.cleanReady.rawValue
            saveContext()
            loadCaptures()
        } catch {
            entity.ackTitle = "整理失败"
            entity.ackDetail = "点此重试"
            saveContext()
            loadCaptures()
        }
    }

    private func updateAssistArchive(for entity: CaptureEntity, questionText: String) async {
        let item = makeCaptureItem(from: entity, assistPayload: nil)

        do {
            let payload = try await aiService.assistArchive(for: item, questionText: questionText)
            saveArtifact(for: entity, payload: payload)
            saveContext()
            loadCaptures()
        } catch {
            let fallback = AssistArchivePayload(
                reply: "整理失败，稍后再试。",
                card: AssistArchiveCard(
                    title: "未能生成卡片",
                    context: "请求失败",
                    keyPoints: [],
                    nextSteps: [],
                    tagSuggestions: [],
                    confidence: "low"
                ),
                turnPolicy: AssistTurnPolicy(usedClarification: false, turnsRemaining: 0)
            )
            saveArtifact(for: entity, payload: fallback)
            saveContext()
            loadCaptures()
        }
    }

    private func makeCaptureItem(from entity: CaptureEntity, assistPayload: AssistArchivePayload?) -> CaptureItem {
        let mode = CaptureInputMode(rawValue: entity.mode ?? "") ?? .log
        let state = resolveProcessingState(from: entity)
        return CaptureItem(
            id: entity.id,
            createdAt: entity.createdAt,
            rawText: entity.rawText,
            cleanText: entity.cleanText,
            ackTitle: entity.ackTitle,
            ackDetail: entity.ackDetail,
            dayPart: dayPart(for: entity.createdAt, fallback: entity.dayPart),
            mode: mode,
            assistPayload: assistPayload,
            atomsCount: Int(entity.atomsCount),
            processingState: state
        )
    }

    private func resolveProcessingState(from entity: CaptureEntity) -> CaptureProcessingState {
        if let stored = entity.processingState,
           let state = CaptureProcessingState(rawValue: stored) {
            return state
        }

        if entity.cleanText == nil {
            return .pendingClean
        }

        if entity.atomsCount > 0 {
            return .atomsReady
        }

        return .cleanReady
    }

    private func loadArtifacts(for captureIds: [UUID]) -> [UUID: AssistArchivePayload] {
        guard !captureIds.isEmpty else { return [:] }

        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "sourceCaptureID IN %@", captureIds)

        do {
            let artifacts = try context.fetch(request)
            return artifacts.reduce(into: [:]) { result, artifact in
                guard let payload = AssistArchivePayload.decode(from: artifact.contentJSON) else { return }
                result[artifact.sourceCaptureID] = payload
            }
        } catch {
            return [:]
        }
    }

    private func saveArtifact(for entity: CaptureEntity, payload: AssistArchivePayload) {
        let artifact = ArtifactEntity(context: context)
        artifact.id = UUID()
        artifact.artifactType = "assist_archive_card"
        artifact.title = payload.card.title
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.sourceCaptureID = entity.id
        artifact.createdAt = Date()
        artifact.updatedAt = Date()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    private func dayPart(for date: Date, fallback: String?) -> DayPart {
        if let fallback = fallback, let stored = DayPart(rawValue: fallback) {
            return stored
        }

        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
    }
}
