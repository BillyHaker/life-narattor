import CoreData
import Foundation

struct ReviewMaterialRepairSummary {
    var inspected = 0
    var backfilled = 0
    var skipped = 0
}

struct ReviewMaterialRepairService {
    let context: NSManagedObjectContext

    private let atomizationPayloadArtifactType = "atomization_payload"
    private let assistArchiveArtifactType = "assist_archive_card"

    @discardableResult
    func backfillLegacyAssistArchivePayloads(for captures: [CaptureEntity]) -> ReviewMaterialRepairSummary {
        var summary = ReviewMaterialRepairSummary()
        var didMutate = false

        for capture in captures {
            summary.inspected += 1

            guard capture.isFormalRecord else {
                summary.skipped += 1
                continue
            }

            let existingPayload = fetchPayloadArtifact(captureID: capture.id)
            if let existingPayload,
               let decoded = AtomizationArtifactPayload.decode(from: existingPayload.contentJSON),
               !decoded.recordUnits.isEmpty {
                summary.skipped += 1
                continue
            }

            guard let archiveArtifact = fetchAssistArchiveArtifact(captureID: capture.id),
                  let archivePayload = AssistArchivePayload.decode(from: archiveArtifact.contentJSON),
                  let payload = buildPayload(from: archivePayload, fallbackText: capture.normalizedCleanTextForReview) else {
                summary.skipped += 1
                continue
            }

            let targetArtifact = existingPayload ?? ArtifactEntity(context: context)
            if existingPayload == nil {
                targetArtifact.id = UUID()
                targetArtifact.artifactType = atomizationPayloadArtifactType
                targetArtifact.sourceCaptureID = capture.id
                targetArtifact.createdAt = Date()
            }
            targetArtifact.title = atomizationPayloadArtifactType
            targetArtifact.contentJSON = payload.encodedJSON() ?? "{}"
            targetArtifact.status = "done"
            targetArtifact.updatedAt = Date()
            if capture.atomsCount > 0 {
                capture.processingState = CaptureProcessingState.tagsSuggested.rawValue
            }
            didMutate = true
            summary.backfilled += 1
        }

        if didMutate {
            try? context.save()
        }

        return summary
    }

    @discardableResult
    func backfillLegacyAssistArchivePayloads(in interval: DateInterval) -> ReviewMaterialRepairSummary {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            interval.start as CVarArg,
            interval.end as CVarArg
        )
        let captures = (try? context.fetch(request)) ?? []
        return backfillLegacyAssistArchivePayloads(for: captures)
    }

    private func fetchAssistArchiveArtifact(captureID: UUID) -> ArtifactEntity? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            assistArchiveArtifactType,
            captureID as CVarArg
        )
        return try? context.fetch(request).first
    }

    private func fetchPayloadArtifact(captureID: UUID) -> ArtifactEntity? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            atomizationPayloadArtifactType,
            captureID as CVarArg
        )
        return try? context.fetch(request).first
    }

    private func buildPayload(from archive: AssistArchivePayload, fallbackText: String?) -> AtomizationArtifactPayload? {
        let tagHints = archive.card.tagSuggestions.map(\.name)
        let confidence = normalizedConfidence(from: archive.card.confidence)
        let units = archive.card.effectiveRecordUnits
            .enumerated()
            .map { index, unit in
                unit.asRecordUnitDraft(tagHints: tagHints, confidence: confidence, sequenceIndex: index)
            }
            .filter { !$0.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        let finalUnits: [RecordUnitDraft]
        if !units.isEmpty {
            finalUnits = units
        } else if let fallbackText, !fallbackText.isEmpty {
            finalUnits = [
                RecordUnitDraft(
                    summary: fallbackText,
                    contextAttributes: [],
                    behavioralChain: [],
                    resultOrState: [],
                    tagHints: Array(NSOrderedSet(array: tagHints)) as? [String] ?? tagHints,
                    confidence: confidence,
                    startChar: nil,
                    endChar: nil
                )
            ]
        } else {
            return nil
        }

        let semanticChunks = finalUnits.enumerated().map { index, unit in
            SemanticChunkDraft(
                text: unit.summary,
                kind: "assist_archive",
                sequenceIndex: index
            )
        }

        return AtomizationArtifactPayload(
            semanticChunks: semanticChunks,
            recordUnits: finalUnits,
            atomizeVersion: "assist_archive_backfill_v1"
        )
    }

    private func normalizedConfidence(from raw: String) -> Double? {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "high":
            return 0.82
        case "medium":
            return 0.65
        case "low":
            return 0.45
        default:
            return nil
        }
    }
}

private extension AssistRecordUnit {
    func asRecordUnitDraft(tagHints: [String], confidence: Double?, sequenceIndex: Int) -> RecordUnitDraft {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let composedSummary: String
        if !cleanedTitle.isEmpty, !cleanedSummary.isEmpty, !cleanedSummary.contains(cleanedTitle) {
            composedSummary = "\(cleanedTitle)：\(cleanedSummary)"
        } else {
            composedSummary = !cleanedSummary.isEmpty ? cleanedSummary : cleanedTitle
        }

        let uniqueTagHints = Array(NSOrderedSet(array: tagHints)) as? [String] ?? tagHints
        return RecordUnitDraft(
            summary: composedSummary,
            contextAttributes: [],
            behavioralChain: keyPoints,
            resultOrState: nextSteps,
            tagHints: uniqueTagHints,
            confidence: confidence,
            startChar: nil,
            endChar: nil
        )
    }
}
