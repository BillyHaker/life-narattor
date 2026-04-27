import CoreData
import Foundation

struct IndexedTagSignal: Hashable {
    let type: TagType
    let name: String
    let source: RetrievalTagSource
    let isVisible: Bool
}

struct IndexedCaptureSnapshot: Identifiable {
    let id: UUID
    let createdAt: Date
    let rawText: String
    let cleanText: String
    let semanticChunks: [SemanticChunkDraft]
    let units: [RecordUnitDraft]
    let visibleTags: [IndexedTagSignal]
    let hiddenTags: [IndexedTagSignal]
    let tagHints: [String]
    let systemSignals: [SystemSignal]
    let score: Double
}

struct MemoryIndexStore {
    let context: NSManagedObjectContext

    func search(plan: RetrievalPlan) -> [IndexedCaptureSnapshot] {
        fetchCandidates(in: plan.timeRange)
            .map { snapshot in
                let score = score(snapshot: snapshot, plan: plan)
                return IndexedCaptureSnapshot(
                    id: snapshot.id,
                    createdAt: snapshot.createdAt,
                    rawText: snapshot.rawText,
                    cleanText: snapshot.cleanText,
                    semanticChunks: snapshot.semanticChunks,
                    units: snapshot.units,
                    visibleTags: snapshot.visibleTags,
                    hiddenTags: snapshot.hiddenTags,
                    tagHints: snapshot.tagHints,
                    systemSignals: snapshot.systemSignals,
                    score: score
                )
            }
            .filter { shouldInclude(snapshot: $0, plan: plan) }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.createdAt > rhs.createdAt
                }
                return lhs.score > rhs.score
            }
            .prefix(plan.compressionPolicy.maxCaptures)
            .map { $0 }
    }

    func buildNarrativeBrief(plan: RetrievalPlan) -> NarrativeBrief {
        let snapshots = search(plan: plan)
        let units = snapshots.flatMap { snapshot in
            snapshot.units.map { unit in
                NarrativeBriefUnit(
                    id: UUID(),
                    captureID: snapshot.id,
                    createdAt: snapshot.createdAt,
                    summary: unit.summary,
                    contextAttributes: unit.contextAttributes,
                    behavioralChain: unit.behavioralChain,
                    resultOrState: unit.resultOrState,
                    visibleTags: snapshot.visibleTags.map(\.name).sorted(),
                    hiddenTags: snapshot.hiddenTags.map(\.name).sorted(),
                    tagHints: unit.tagHints,
                    systemSignals: snapshot.systemSignals,
                    score: snapshot.score + (unit.confidence ?? 0)
                )
            }
        }

        return NarrativeBrief(
            plan: plan,
            generatedAt: Date(),
            units: units,
            topVisibleTags: topNames(from: snapshots.flatMap { $0.visibleTags.map(\.name) }, limit: 6),
            topHiddenTags: topNames(
                from: snapshots.flatMap { $0.hiddenTags.map(\.name) + $0.tagHints },
                limit: 8,
                minCount: 2
            ),
            overviewPoints: makeOverviewPoints(from: units)
        )
    }

    private func fetchCandidates(in range: RetrievalTimeRange) -> [IndexedCaptureSnapshot] {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", range.start as CVarArg, range.end as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let captures = (try? context.fetch(request)) ?? []
        _ = ReviewMaterialRepairService(context: context).backfillLegacyAssistArchivePayloads(for: captures)
        return captures
            .filter(\.isEligibleForReviewTimeline)
            .map(makeSnapshot)
    }

    private func makeSnapshot(for entity: CaptureEntity) -> IndexedCaptureSnapshot {
        let payload = fetchAtomizationPayload(captureID: entity.id)
        let units = payload?.recordUnits ?? []
        let signals = fetchTagSignals(captureID: entity.id)
        let hints = Array(NSOrderedSet(array: units.flatMap(\.tagHints))) as? [String] ?? units.flatMap(\.tagHints)

        return IndexedCaptureSnapshot(
            id: entity.id,
            createdAt: entity.createdAt,
            rawText: entity.rawText,
            cleanText: entity.cleanText ?? entity.rawText,
            semanticChunks: payload?.semanticChunks ?? [],
            units: units,
            visibleTags: signals.filter { $0.isVisible },
            hiddenTags: signals.filter { !$0.isVisible },
            tagHints: hints,
            systemSignals: systemSignals(for: entity),
            score: 0
        )
    }

    private func fetchAtomizationPayload(captureID: UUID) -> AtomizationArtifactPayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@ AND sourceCaptureID == %@", "atomization_payload", captureID as CVarArg)
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AtomizationArtifactPayload.decode(from: artifact.contentJSON)
    }

    private func fetchTagSignals(captureID: UUID) -> [IndexedTagSignal] {
        let normalizationMap = fetchHiddenTagNormalizationMap()
        let atomRequest = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        atomRequest.predicate = NSPredicate(format: "captureID == %@", captureID as CVarArg)
        guard let atoms = try? context.fetch(atomRequest), !atoms.isEmpty else { return [] }
        let atomIDs = atoms.map(\.id)

        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)
        guard let links = try? context.fetch(linkRequest), !links.isEmpty else { return [] }

        let tagIDs = links.map(\.tagID)
        let tagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        tagRequest.predicate = NSPredicate(format: "id IN %@", tagIDs)
        let tags = (try? context.fetch(tagRequest)) ?? []
        let tagsByID = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })

        let signals = links.compactMap { link -> IndexedTagSignal? in
            guard let tag = tagsByID[link.tagID], let type = TagType(rawValue: tag.type) else { return nil }
            let canonicalName = (!tag.isUserVisible ? normalizationMap?.canonicalName(for: tag.id) : nil) ?? tag.name
            return IndexedTagSignal(
                type: type,
                name: canonicalName,
                source: tag.isUserVisible ? .explicit : .hidden,
                isVisible: tag.isUserVisible
            )
        }
        return Array(Set(signals))
    }

    private func fetchHiddenTagNormalizationMap() -> HiddenTagNormalizationMap? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(
            format: "artifactType == %@ AND sourceCaptureID == %@",
            hiddenTagNormalizationArtifactType,
            hiddenTagNormalizationSourceID as CVarArg
        )
        guard let artifact = try? context.fetch(request).first,
              let data = artifact.contentJSON.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(HiddenTagNormalizationMap.self, from: data)
    }

    private func score(snapshot: IndexedCaptureSnapshot, plan: RetrievalPlan) -> Double {
        var total = 0.0

        let allVisible = Set(snapshot.visibleTags.map { "\($0.type.rawValue):\($0.name.lowercased())" })
        let allHidden = Set(snapshot.hiddenTags.map { "\($0.type.rawValue):\($0.name.lowercased())" })
        let allHints = Set(snapshot.tagHints.map { $0.lowercased() })

        for filter in plan.primaryFilters {
            let key = "\(filter.type.rawValue):\(filter.name.lowercased())"
            if allVisible.contains(key) {
                total += plan.rankingWeights.primaryTagMatch * filter.strength * scopeWeight(type: filter.type, plan: plan)
            } else if allHidden.contains(key) {
                total += hiddenMatchWeight(
                    filterName: filter.name,
                    filterType: filter.type,
                    filterStrength: filter.strength,
                    scopeWeight: scopeWeight(type: filter.type, plan: plan),
                    allHidden: allHidden,
                    allHints: allHints,
                    rankingWeight: plan.rankingWeights.hiddenTagMatch
                )
            } else if allHints.contains(filter.name.lowercased()) {
                total += plan.rankingWeights.hintMatch * filter.strength
            }
        }

        for filter in plan.secondaryFilters {
            let key = "\(filter.type.rawValue):\(filter.name.lowercased())"
            if allVisible.contains(key) {
                total += plan.rankingWeights.secondaryTagMatch * filter.strength * scopeWeight(type: filter.type, plan: plan)
            } else if allHidden.contains(key) {
                total += hiddenMatchWeight(
                    filterName: filter.name,
                    filterType: filter.type,
                    filterStrength: filter.strength,
                    scopeWeight: 0.8,
                    allHidden: allHidden,
                    allHints: allHints,
                    rankingWeight: plan.rankingWeights.hiddenTagMatch
                )
            } else if allHints.contains(filter.name.lowercased()) {
                total += plan.rankingWeights.hintMatch * filter.strength * 0.8
            }
        }

        if plan.mode == .overview {
            let unitCount = max(snapshot.units.count, 1)
            total += Double(unitCount - 1) * plan.rankingWeights.novelty
            let stateCount = snapshot.units.flatMap(\.resultOrState).count
            total += Double(stateCount) * plan.rankingWeights.stateChange * 0.3
        }

        return total
    }

    private func shouldInclude(snapshot: IndexedCaptureSnapshot, plan: RetrievalPlan) -> Bool {
        if snapshot.score > 0 {
            return true
        }
        return plan.mode == .overview && !snapshot.units.isEmpty
    }

    private func systemSignals(for entity: CaptureEntity) -> [SystemSignal] {
        let calendar = Calendar.current
        let createdAt = entity.createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.calendar = calendar

        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateValue = dateFormatter.string(from: createdAt)

        dateFormatter.dateFormat = "yyyy-MM"
        let monthValue = dateFormatter.string(from: createdAt)

        dateFormatter.dateFormat = "EEEE"
        let weekdayValue = dateFormatter.string(from: createdAt)

        let weekYear = calendar.component(.yearForWeekOfYear, from: createdAt)
        let weekOfYear = calendar.component(.weekOfYear, from: createdAt)
        let weekValue = String(format: "%04d-W%02d", weekYear, weekOfYear)

        let dayPart = DayPart(rawValue: entity.dayPart ?? "") ?? dayPart(for: createdAt)
        let inputType = CaptureInputType(rawValue: entity.inputType ?? "") ?? .text
        let mode = entity.resolvedInputMode
        let processingState = entity.resolvedReviewProcessingState

        return [
            SystemSignal(kind: .date, value: dateValue, displayName: "日期：\(dateValue)"),
            SystemSignal(kind: .week, value: weekValue, displayName: "周：\(weekValue)"),
            SystemSignal(kind: .month, value: monthValue, displayName: "月份：\(monthValue)"),
            SystemSignal(kind: .weekday, value: weekdayValue, displayName: "星期：\(weekdayValue)"),
            SystemSignal(kind: .dayPart, value: dayPart.title, displayName: "时间段：\(dayPart.title)"),
            SystemSignal(kind: .inputType, value: inputType.rawValue, displayName: "输入方式：\(inputTypeTitle(inputType))"),
            SystemSignal(kind: .source, value: mode.rawValue, displayName: "来源：\(mode.title)"),
            SystemSignal(kind: .processingState, value: processingState.rawValue, displayName: "处理状态：\(processingState.displayText)")
        ]
    }

    private func dayPart(for date: Date) -> DayPart {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
    }

    private func inputTypeTitle(_ inputType: CaptureInputType) -> String {
        switch inputType {
        case .text:
            return "文字"
        case .voice:
            return "语音"
        }
    }

    private func scopeWeight(type: TagType, plan: RetrievalPlan) -> Double {
        switch type {
        case .project:
            return plan.tagScopeWeights.project
        case .habit:
            return plan.tagScopeWeights.habit
        case .theme:
            return plan.tagScopeWeights.theme
        case .person:
            return plan.tagScopeWeights.person
        case .goal:
            return plan.tagScopeWeights.goal
        case .context:
            return plan.tagScopeWeights.context
        }
    }

    private func hiddenMatchWeight(
        filterName: String,
        filterType: TagType,
        filterStrength: Double,
        scopeWeight: Double,
        allHidden: Set<String>,
        allHints: Set<String>,
        rankingWeight: Double
    ) -> Double {
        let hiddenKey = "\(filterType.rawValue):\(filterName.lowercased())"
        guard allHidden.contains(hiddenKey) else { return 0 }
        let hintSupport = allHints.contains(filterName.lowercased()) ? 1.0 : 0.65
        return rankingWeight * filterStrength * scopeWeight * hintSupport
    }

    private func topNames(from values: [String], limit: Int, minCount: Int = 1) -> [String] {
        let counts = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .reduce(into: [String: Int]()) { result, value in
                result[value, default: 0] += 1
            }

        return counts
            .filter { $0.value >= minCount }
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(limit)
            .map(\.key)
    }

    private func makeOverviewPoints(from units: [NarrativeBriefUnit]) -> [String] {
        units
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.createdAt > rhs.createdAt
                }
                return lhs.score > rhs.score
            }
            .prefix(5)
            .map { unit in
                let contextText = unit.contextAttributes.prefix(2)
                    .map { "\($0.name)：\($0.value)" }
                    .joined(separator: "，")
                let resultText = unit.resultOrState.first.map { "结果：\($0)" }
                return [unit.summary, contextText.isEmpty ? nil : contextText, resultText]
                    .compactMap { $0 }
                    .joined(separator: "｜")
            }
    }
}
