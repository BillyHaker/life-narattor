import Foundation

struct FocusedEvidenceBuilder {
    func build(from brief: NarrativeBrief) -> FocusedEvidenceBundle {
        let sortedUnits = brief.units.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.score > rhs.score
        }

        let groups = makeEvidenceGroups(from: sortedUnits, plan: brief.plan)
        return FocusedEvidenceBundle(
            plan: brief.plan,
            generatedAt: brief.generatedAt,
            leadingQuestion: brief.plan.query,
            topSignals: topSignals(from: sortedUnits),
            comparisonWindows: comparisonWindows(from: sortedUnits, plan: brief.plan),
            evidenceGroups: groups
        )
    }

    private func makeEvidenceGroups(from units: [NarrativeBriefUnit], plan: RetrievalPlan) -> [FocusedEvidenceGroup] {
        switch plan.questionShape {
        case .comparison:
            return buildComparisonGroups(from: units)
        case .relation:
            return buildRelationGroups(from: units)
        default:
            return buildTopicGroups(from: units)
        }
    }

    private func buildComparisonGroups(from units: [NarrativeBriefUnit]) -> [FocusedEvidenceGroup] {
        guard !units.isEmpty else { return [] }
        let sortedByTime = units.sorted { $0.createdAt < $1.createdAt }
        let midpoint = max(sortedByTime.count / 2, 1)
        let before = Array(sortedByTime.prefix(midpoint))
        let after = Array(sortedByTime.suffix(sortedByTime.count - midpoint))

        var groups: [FocusedEvidenceGroup] = []
        if !before.isEmpty {
            groups.append(
                FocusedEvidenceGroup(
                    id: UUID(),
                    title: "前段样本",
                    rationale: "用于观察较早阶段与“\(anchorLabel(from: before.first))”相关的状态、行为和结果。",
                    units: Array(before.suffix(5))
                )
            )
        }
        if !after.isEmpty {
            groups.append(
                FocusedEvidenceGroup(
                    id: UUID(),
                    title: "后段样本",
                    rationale: "用于观察较晚阶段与“\(anchorLabel(from: after.first))”相关的状态、行为和结果。",
                    units: Array(after.prefix(5))
                )
            )
        }
        return groups
    }

    private func buildRelationGroups(from units: [NarrativeBriefUnit]) -> [FocusedEvidenceGroup] {
        let withStates = units.filter { !$0.resultOrState.isEmpty }
        let withBehavior = units.filter { !$0.behavioralChain.isEmpty }

        var groups: [FocusedEvidenceGroup] = []
        if !withBehavior.isEmpty {
            groups.append(
                FocusedEvidenceGroup(
                    id: UUID(),
                    title: "相关行为证据",
                    rationale: "这些事项包含较明确的动作或过程线索，可用于观察与当前问题相关的可能触发因素。",
                    units: Array(withBehavior.prefix(6))
                )
            )
        }
        if !withStates.isEmpty {
            groups.append(
                FocusedEvidenceGroup(
                    id: UUID(),
                    title: "相关状态证据",
                    rationale: "这些事项包含较明确的结果、感受或状态变化，可用于观察与当前问题相关的结果变化。",
                    units: Array(withStates.prefix(6))
                )
            )
        }
        return groups
    }

    private func buildTopicGroups(from units: [NarrativeBriefUnit]) -> [FocusedEvidenceGroup] {
        let top = Array(units.prefix(8))
        guard !top.isEmpty else { return [] }
        return [
            FocusedEvidenceGroup(
                id: UUID(),
                title: "高相关事项",
                rationale: "这些事项与当前问题最相关，优先作为 focused 回答的主证据。",
                units: top
            )
        ]
    }

    private func topSignals(from units: [NarrativeBriefUnit]) -> [String] {
        let values = units.flatMap { unit in
            unit.resultOrState + unit.visibleTags + unit.hiddenTags + unit.tagHints
        }
        let counts = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .reduce(into: [String: Int]()) { result, value in
                result[value, default: 0] += 1
            }

        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(6)
            .map(\.key)
    }

    private func comparisonWindows(from units: [NarrativeBriefUnit], plan: RetrievalPlan) -> [String] {
        guard !units.isEmpty else { return [] }
        if plan.questionShape == .comparison {
            let sorted = units.sorted { $0.createdAt < $1.createdAt }
            guard let first = sorted.first?.createdAt, let last = sorted.last?.createdAt else { return [] }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日"
            let anchor = plan.focusAnchor.map { "围绕\($0)" } ?? "围绕当前问题"
            return ["\(anchor)的较早样本：\(formatter.string(from: first))附近", "\(anchor)的较晚样本：\(formatter.string(from: last))附近"]
        }
        if plan.questionShape == .relation, plan.relationAnchors.count >= 2 {
            return ["关系对照：\(plan.relationAnchors[0])", "关系对照：\(plan.relationAnchors[1])"]
        }
        return []
    }

    private func anchorLabel(from unit: NarrativeBriefUnit?) -> String {
        guard let unit else { return "当前主题" }
        return unit.contextAttributes.first?.value ?? unit.summary
    }
}
