import CoreData
import Foundation

struct ReviewRetrievalService {
    let context: NSManagedObjectContext

    func makeOpenReviewBrief(periodLabel: String, range: RetrievalTimeRange) -> NarrativeBrief {
        let tagLibrary = loadVisibleTagLibrary()
        let builder = RetrievalPlanBuilder(tagLibrary: tagLibrary, now: range.end)
        let plan = builder.makeOpenReviewPlan(periodLabel: periodLabel, range: range)
        let indexStore = MemoryIndexStore(context: context)
        return indexStore.buildNarrativeBrief(plan: plan)
    }

    func makeNarrativeMaterial(from brief: NarrativeBrief) -> NarrativeMaterial {
        NarrativeMaterialBuilder().build(from: brief)
    }

    func makeFocusedEvidence(from brief: NarrativeBrief) -> FocusedEvidenceBundle {
        FocusedEvidenceBuilder().build(from: brief)
    }

    func makeFocusedEvidence(query: String, timeRangeOverride: RetrievalTimeRange? = nil) -> FocusedEvidenceBundle {
        let tagLibrary = loadVisibleTagLibrary()
        let builder = RetrievalPlanBuilder(tagLibrary: tagLibrary)
        let plan = builder.build(query: query, timeRangeOverride: timeRangeOverride)
        let indexStore = MemoryIndexStore(context: context)
        let brief = indexStore.buildNarrativeBrief(plan: plan)
        return makeFocusedEvidence(from: brief)
    }

    func makeNarrativeText(from material: NarrativeMaterial, periodName: String) -> String {
        guard !material.representativeUnits.isEmpty else { return "" }

        let themeText = material.primaryThemes.prefix(4).joined(separator: "、")
        let changeText = material.changeSignals.prefix(2).joined(separator: "；")
        let representativeText = material.representativeUnits.prefix(2).map(\.summary).joined(separator: "；")

        let lead = themeText.isEmpty ? "\(periodName)主要有这些内容" : "\(periodName)主要围绕\(themeText)"
        let body = [changeText.isEmpty ? nil : "明显变化包括：\(changeText)", representativeText.isEmpty ? nil : "代表性片段有：\(representativeText)"]
            .compactMap { $0 }
            .joined(separator: "。")
        return body.isEmpty ? "\(lead)。" : "\(lead)。\(body)。"
    }

    func makeFocusedEvidenceText(from bundle: FocusedEvidenceBundle) -> String {
        guard !bundle.evidenceGroups.isEmpty else { return "" }

        let signalText = bundle.topSignals.prefix(3).joined(separator: "、")
        let windowText = bundle.comparisonWindows.prefix(2).joined(separator: "；")
        let groupText = bundle.evidenceGroups.prefix(2).map { group in
            let sampleText = group.units.prefix(2).map(\.summary).joined(separator: "；")
            guard !sampleText.isEmpty else { return "\(group.title)：\(group.rationale)" }
            return "\(group.title)：\(sampleText)"
        }.joined(separator: "。")

        let lead = "围绕“\(bundle.leadingQuestion)”整理了这些证据"
        let detailParts = [
            signalText.isEmpty ? nil : "高频线索有：\(signalText)",
            windowText.isEmpty ? nil : windowText,
            groupText.isEmpty ? nil : groupText
        ].compactMap { $0 }

        return detailParts.isEmpty ? "\(lead)。" : "\(lead)。\(detailParts.joined(separator: "。"))。"
    }

    func buildDays(from material: NarrativeMaterial) -> [TimelineDay] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: material.representativeUnits) { unit in
            calendar.startOfDay(for: unit.createdAt)
        }

        return grouped.map { date, units in
            let sorted = units.sorted { $0.createdAt > $1.createdAt }
            let highlights = sorted.map(\.summary).prefix(6)
            let captureIDs = sorted.map(\.captureID).prefix(6)
            return TimelineDay(
                id: UUID(),
                date: date,
                highlights: Array(highlights),
                highlightCaptureIDs: Array(captureIDs),
                hasNarrative: units.count >= 2
            )
        }
        .sorted { $0.date > $1.date }
    }

    private func loadVisibleTagLibrary() -> TagLibrary {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES")
        let tags = (try? context.fetch(request)) ?? []
        let grouped = Dictionary(grouping: tags.compactMap { tag -> (TagType, String)? in
            guard let type = TagType(rawValue: tag.type) else { return nil }
            return (type, tag.name)
        }, by: \.0)

        return TagLibrary(
            project: grouped[.project]?.map(\.1) ?? [],
            habit: grouped[.habit]?.map(\.1) ?? [],
            theme: grouped[.theme]?.map(\.1) ?? [],
            person: grouped[.person]?.map(\.1) ?? [],
            goal: grouped[.goal]?.map(\.1) ?? [],
            context: grouped[.context]?.map(\.1) ?? []
        )
    }
}
