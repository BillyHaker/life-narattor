import CoreData
import Foundation

@MainActor
struct AtomizationCoordinator {
    let context: NSManagedObjectContext
    let aiService: AIService

    private var atomStore: AtomTagStore { AtomTagStore(context: context) }

    func atomizeCaptureIfNeeded(captureID: UUID, cleanText: String) async {
        guard !cleanText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let tagLibrary = loadTagLibrary()
        do {
            let capture = fetchCaptureItem(id: captureID, cleanText: cleanText)
            let result = try await aiService.atomize(capture: capture, tagLibrary: tagLibrary)
            let drafts = result.atoms.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            guard !drafts.isEmpty else {
                atomizeFallback(captureID: captureID, cleanText: cleanText)
                return
            }

            let atomIDs = atomStore.replaceAtoms(with: drafts, captureID: captureID)
            let suggestions = try? await aiService.suggestTags(atoms: drafts, tagLibrary: tagLibrary)
            if let suggestions {
                atomStore.assignTagSuggestions(suggestions.suggestions, to: atomIDs, isHidden: false)
                atomStore.assignTagSuggestions(suggestions.hiddenSuggestions, to: atomIDs, isHidden: true)
            }

            let hasVisibleSuggestions = !(suggestions?.suggestions ?? []).isEmpty
            atomStore.updateCaptureStats(
                captureID: captureID,
                atomsCount: atomIDs.count,
                processingState: hasVisibleSuggestions ? .tagsSuggested : .atomsReady
            )
            LogStore.shared.log("Atomize=OpenAI", category: .ai)
        } catch {
            atomizeFallback(captureID: captureID, cleanText: cleanText)
            LogStore.shared.log("Atomize=Fallback (\(error.localizedDescription))", category: .ai)
        }
    }

    private func atomizeFallback(captureID: UUID, cleanText: String) {
        let count = atomStore.createAtoms(from: cleanText, captureID: captureID)
        if count > 0 {
            atomStore.updateCaptureStats(
                captureID: captureID,
                atomsCount: count,
                processingState: .atomsReady
            )
        }
    }

    private func loadTagLibrary() -> TagLibrary {
        TagLibrary(
            project: fetchTagNames(type: .project),
            theme: fetchTagNames(type: .theme),
            person: fetchTagNames(type: .person),
            goal: fetchTagNames(type: .goal)
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
            transcriptionStatus: TranscriptionStatus(rawValue: entity?.transcriptionStatus ?? "")
        )
    }
}
