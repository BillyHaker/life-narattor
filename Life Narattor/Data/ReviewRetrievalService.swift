import CoreData
import Foundation

struct RangeReviewSection: Identifiable {
    let id: UUID
    let title: String
    let accent: String
    let bullets: [String]
}

struct RangeReviewEvidenceGroup: Identifiable {
    let id: UUID
    let title: String
    let rationale: String
    let highlights: [String]
    let sourceDays: [TimelineDay]
}

struct RangeReviewData {
    let range: RetrievalTimeRange
    let periodName: String
    let periodLabel: String
    let totalRecordCount: Int
    let activeDayCount: Int
    let summaryText: String
    let overviewSignals: [String]
    let sections: [RangeReviewSection]
    let evidenceGroups: [RangeReviewEvidenceGroup]
    let followupPrompts: [String]
    let sourceDays: [TimelineDay]
    let material: NarrativeMaterial
}

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
            let snippets = sorted.map(\.summary)
            let captureIDs = Array(sorted.dropFirst().map(\.captureID).prefix(2))
            let parts = sorted.compactMap { unit in
                unit.systemSignals.first(where: { $0.kind == .dayPart })?.value
            }
            let dayParts = Array(NSOrderedSet(array: parts.compactMap(DayPart.init(rawValue:)))) as? [DayPart] ?? []
            let primaryLine = snippets.first ?? "这一天留下了一些片段。"
            let secondaryLines = Array(snippets.dropFirst().prefix(2))
            return TimelineDay(
                id: UUID(),
                date: date,
                recordCount: units.count,
                dayParts: dayParts,
                primaryLine: primaryLine,
                secondaryLines: secondaryLines,
                highlightCaptureIDs: captureIDs,
                hasGeneratedNarrative: false
            )
        }
        .sorted { $0.date > $1.date }
    }

    func makeRangeReviewData(periodName: String, periodLabel: String, range: RetrievalTimeRange) -> RangeReviewData? {
        let brief = makeOpenReviewBrief(periodLabel: periodLabel, range: range)
        let material = makeNarrativeMaterial(from: brief)
        guard !material.representativeUnits.isEmpty else { return nil }

        let sourceDays = buildDays(from: material)
        let evidenceGroups = buildRangeEvidenceGroups(from: material, sourceDays: sourceDays)
        let overviewSignals = Array((material.primaryThemes + material.changeSignals + material.repeatedPatterns).prefix(4))
        let sections = buildRangeSections(from: material)
        let summaryText = makeNarrativeText(from: material, periodName: periodName)
        let followupPrompts = makeRangeFollowupPrompts(from: material, periodName: periodName)

        return RangeReviewData(
            range: range,
            periodName: periodName,
            periodLabel: periodLabel,
            totalRecordCount: brief.units.count,
            activeDayCount: sourceDays.count,
            summaryText: summaryText,
            overviewSignals: overviewSignals,
            sections: sections,
            evidenceGroups: evidenceGroups,
            followupPrompts: followupPrompts,
            sourceDays: sourceDays,
            material: material
        )
    }

    private func buildRangeSections(from material: NarrativeMaterial) -> [RangeReviewSection] {
        var sections: [RangeReviewSection] = []

        if !material.primaryThemes.isEmpty {
            sections.append(
                RangeReviewSection(
                    id: UUID(),
                    title: "这段时间反复出现的主题",
                    accent: "主题",
                    bullets: Array(material.primaryThemes.prefix(4))
                )
            )
        }

        if !material.changeSignals.isEmpty {
            sections.append(
                RangeReviewSection(
                    id: UUID(),
                    title: "比较明显的变化",
                    accent: "变化",
                    bullets: Array(material.changeSignals.prefix(3))
                )
            )
        }

        if !material.repeatedPatterns.isEmpty {
            sections.append(
                RangeReviewSection(
                    id: UUID(),
                    title: "值得继续留意的重复模式",
                    accent: "模式",
                    bullets: Array(material.repeatedPatterns.prefix(3))
                )
            )
        }

        if !material.turningPoints.isEmpty {
            sections.append(
                RangeReviewSection(
                    id: UUID(),
                    title: "这段时间的关键转折",
                    accent: "转折",
                    bullets: Array(material.turningPoints.prefix(3))
                )
            )
        }

        return sections
    }

    private func buildRangeEvidenceGroups(from material: NarrativeMaterial, sourceDays: [TimelineDay]) -> [RangeReviewEvidenceGroup] {
        let dayLookup = Dictionary(uniqueKeysWithValues: sourceDays.map { (Calendar.current.startOfDay(for: $0.date), $0) })

        var groups: [RangeReviewEvidenceGroup] = []

        if !material.primaryThemes.isEmpty {
            let themeBullets = material.representativeUnits
                .filter { unit in
                    !Set(unit.visibleTags + unit.hiddenTags + unit.tagHints).isDisjoint(with: material.primaryThemes)
                }
                .prefix(3)
                .map(\.summary)

            if !themeBullets.isEmpty {
                groups.append(
                    RangeReviewEvidenceGroup(
                        id: UUID(),
                        title: "围绕核心主题的片段",
                        rationale: "这些片段最能说明这段时间反复出现的关注点。",
                        highlights: Array(themeBullets),
                        sourceDays: sourceDaysForUnits(material.representativeUnits, dayLookup: dayLookup)
                    )
                )
            }
        }

        if !material.changeSignals.isEmpty {
            let changeBullets = material.representativeUnits
                .filter { !$0.resultOrState.isEmpty }
                .prefix(3)
                .map { unit in
                    if let first = unit.resultOrState.first {
                        return "\(unit.summary)｜\(first)"
                    }
                    return unit.summary
                }

            if !changeBullets.isEmpty {
                groups.append(
                    RangeReviewEvidenceGroup(
                        id: UUID(),
                        title: "能看出变化的片段",
                        rationale: "这些内容更容易看出状态、结果或感受上的波动。",
                        highlights: Array(changeBullets),
                        sourceDays: sourceDaysForUnits(material.representativeUnits.filter { !$0.resultOrState.isEmpty }, dayLookup: dayLookup)
                    )
                )
            }
        }

        let patternBullets = material.representativeUnits
            .filter { !$0.contextAttributes.isEmpty || !$0.tagHints.isEmpty }
            .prefix(3)
            .map(\.summary)

        if !patternBullets.isEmpty {
            groups.append(
                RangeReviewEvidenceGroup(
                    id: UUID(),
                    title: "重复出现的场景和线索",
                    rationale: "这些片段帮助判断哪些模式不是偶发，而是在重复发生。",
                    highlights: Array(patternBullets),
                    sourceDays: sourceDaysForUnits(material.representativeUnits.filter { !$0.contextAttributes.isEmpty || !$0.tagHints.isEmpty }, dayLookup: dayLookup)
                )
            )
        }

        return Array(groups.prefix(3))
    }

    private func sourceDaysForUnits(_ units: [NarrativeBriefUnit], dayLookup: [Date: TimelineDay]) -> [TimelineDay] {
        let dates = units.map { Calendar.current.startOfDay(for: $0.createdAt) }
        var result: [TimelineDay] = []
        var seen: Set<Date> = []

        for date in dates where !seen.contains(date) {
            guard let day = dayLookup[date] else { continue }
            result.append(day)
            seen.insert(date)
        }

        return Array(result.prefix(3))
    }

    private func makeRangeFollowupPrompts(from material: NarrativeMaterial, periodName: String) -> [String] {
        var prompts: [String] = []

        if let firstTheme = material.primaryThemes.first {
            prompts.append("\(periodName)里，关于\(firstTheme)最值得继续看的变化是什么")
        }

        if let firstPattern = material.repeatedPatterns.first {
            prompts.append("这些“\(firstPattern)”背后更像是偶发事件，还是稳定模式")
        }

        if let firstTurningPoint = material.turningPoints.first {
            prompts.append("从“\(firstTurningPoint)”往前后看，最关键的影响因素是什么")
        } else if let firstSignal = material.changeSignals.first {
            prompts.append("\(periodName)里“\(firstSignal)”和哪些事情最相关")
        }

        prompts.append("\(periodName)里还有哪条线索现在看起来不明显，但之后可能重要")
        return Array(NSOrderedSet(array: prompts)) as? [String] ?? prompts
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
