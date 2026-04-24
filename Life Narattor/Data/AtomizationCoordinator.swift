import CoreData
import Foundation

struct AtomizationCoordinator {
    let context: NSManagedObjectContext
    let aiService: AIService
    private let atomizationPayloadArtifactType = "atomization_payload"

    private var atomStore: AtomTagStore { AtomTagStore(context: context) }

    // CRITICAL: Runs on background thread to avoid blocking UI
    // Core Data operations use context.perform to ensure thread safety
    func atomizeCaptureIfNeeded(
        captureID: UUID,
        cleanText: String,
        progress: (@MainActor (String) -> Void)? = nil
    ) async throws {
        guard !cleanText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Load tag library on main context
        await progress?("正在加载标签库…")
        let tagLibrary = await MainActor.run { loadTagLibrary() }

        do {
            // Fetch capture on main context
            await progress?("已发送拆分请求，等待 AI 响应…")
            let capture = await MainActor.run { fetchCaptureItem(id: captureID, cleanText: cleanText) }

            // AI calls run on background thread (not blocking UI)
            let result = try await aiService.atomize(capture: capture, tagLibrary: tagLibrary)
            let drafts = result.atoms.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            guard !drafts.isEmpty else {
                throw AIServiceError.emptyResponse
            }

            // Core Data writes on main context
            await progress?("AI 已返回，正在整理拆分结果…")
            let atomIDs = await MainActor.run {
                saveAtomizationPayload(AtomizationArtifactPayload(result: result), captureID: captureID)
                return atomStore.replaceAtoms(with: drafts, captureID: captureID, atomizeVersion: result.atomizeVersion)
            }

            // Tag suggestion (background AI call)
            await progress?("正在生成标签建议…")
            let suggestions = try? await aiService.suggestTags(atomization: result, tagLibrary: tagLibrary)

            await MainActor.run {
                if let suggestions {
                    // Beta: visible tag recommendations are disabled.
                    // Keep only hidden suggestions for retrieval/indexing.
                    atomStore.assignHiddenTagSuggestions(suggestions.hiddenSuggestions, toAllAtoms: atomIDs)
                }

                atomStore.updateCaptureStats(
                    captureID: captureID,
                    atomsCount: atomIDs.count,
                    processingState: .atomsReady,
                    atomizeVersion: result.atomizeVersion
                )
                LogStore.shared.log("Atomize=OpenAI", category: .ai)
            }
        } catch {
            await MainActor.run {
                LogStore.shared.log("Atomize=Failed (\(error.localizedDescription))", category: .ai)
            }
            throw error
        }
    }

    private func loadTagLibrary() -> TagLibrary {
        TagLibrary(
            project: fetchTagNames(type: .project),
            habit: fetchTagNames(type: .habit),
            theme: fetchTagNames(type: .theme),
            person: fetchTagNames(type: .person),
            goal: fetchTagNames(type: .goal),
            context: fetchTagNames(type: .context)
        )
    }

    private func fetchTagNames(type: TagType) -> [String] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "type == %@ AND isUserVisible == YES", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request).map { $0.name }) ?? []
    }

    private func fetchCaptureItem(id: UUID, cleanText: String) -> CaptureItem {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let entity = try? context.fetch(request).first
        let createdAt = entity?.createdAt ?? Date()
        let rawText = entity?.rawText ?? cleanText
        let dayPart = DayPart(rawValue: entity?.dayPart ?? DayPart.morning.rawValue) ?? .morning
        let mode = CaptureInputMode(rawValue: entity?.mode ?? CaptureInputMode.log.rawValue) ?? .log
        let inputType = CaptureInputType(rawValue: entity?.inputType ?? CaptureInputType.text.rawValue) ?? .text
        let state = CaptureProcessingState(rawValue: entity?.processingState ?? CaptureProcessingState.pendingClean.rawValue) ?? .pendingClean

        return CaptureItem(
            id: id,
            createdAt: createdAt,
            rawText: rawText,
            cleanText: cleanText,
            ackTitle: entity?.ackTitle,
            ackDetail: entity?.ackDetail,
            dayPart: dayPart,
            mode: mode,
            assistRecord: nil,
            atomsCount: Int(entity?.atomsCount ?? 0),
            processingState: state,
            inputType: inputType,
            audioPath: entity?.audioPath,
            transcriptText: entity?.transcriptText,
            transcriptionStatus: TranscriptionStatus(rawValue: entity?.transcriptionStatus ?? ""),
            transcriptionErrorReason: entity?.transcriptionError,
            atomizationErrorReason: entity?.atomizationError,
            isTranscriptionActive: false
        )
    }

    @MainActor
    private func saveAtomizationPayload(_ payload: AtomizationArtifactPayload, captureID: UUID) {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            atomizationPayloadArtifactType,
            captureID as CVarArg
        )
        let existing = (try? context.fetch(request))?.first
        let artifact = existing ?? ArtifactEntity(context: context)
        if existing == nil {
            artifact.id = UUID()
            artifact.createdAt = Date()
            artifact.sourceCaptureID = captureID
            artifact.artifactType = atomizationPayloadArtifactType
        }
        artifact.title = "atomization_payload"
        artifact.contentJSON = payload.encodedJSON() ?? "{}"
        artifact.status = "done"
        artifact.updatedAt = Date()
    }
}
