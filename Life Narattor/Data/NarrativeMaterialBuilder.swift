import Foundation

struct NarrativeMaterialBuilder {
    func build(from brief: NarrativeBrief) -> NarrativeMaterial {
        let representativeUnits = Array(
            brief.units
                .sorted { lhs, rhs in
                    if lhs.score == rhs.score {
                        return lhs.createdAt > rhs.createdAt
                    }
                    return lhs.score > rhs.score
                }
                .prefix(6)
        )

        let primaryThemes = topNames(from: brief.topVisibleTags + brief.topHiddenTags, limit: 6)
        let changeSignals = topSignals(from: representativeUnits)
        let repeatedPatterns = topPatterns(from: brief.units)
        let turningPoints = makeTurningPoints(from: representativeUnits)

        let sections = makeSections(
            themes: primaryThemes,
            changeSignals: changeSignals,
            repeatedPatterns: repeatedPatterns,
            turningPoints: turningPoints,
            representativeUnits: representativeUnits
        )

        return NarrativeMaterial(
            plan: brief.plan,
            generatedAt: brief.generatedAt,
            primaryThemes: primaryThemes,
            changeSignals: changeSignals,
            repeatedPatterns: repeatedPatterns,
            turningPoints: turningPoints,
            representativeUnits: representativeUnits,
            sections: sections
        )
    }

    private func topNames(from values: [String], limit: Int) -> [String] {
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
            .prefix(limit)
            .map(\.key)
    }

    private func topSignals(from units: [NarrativeBriefUnit]) -> [String] {
        let signals = units.flatMap(\.resultOrState)
        return topNames(from: signals, limit: 4)
    }

    private func topPatterns(from units: [NarrativeBriefUnit]) -> [String] {
        let patterns = units.flatMap { unit in
            unit.contextAttributes.map { "\($0.name)：\($0.value)" } + unit.tagHints
        }
        return topNames(from: patterns, limit: 5)
    }

    private func makeTurningPoints(from units: [NarrativeBriefUnit]) -> [String] {
        units
            .filter { !$0.resultOrState.isEmpty }
            .prefix(3)
            .map { unit in
                if let firstResult = unit.resultOrState.first {
                    return "\(unit.summary)｜\(firstResult)"
                }
                return unit.summary
            }
    }

    private func makeSections(
        themes: [String],
        changeSignals: [String],
        repeatedPatterns: [String],
        turningPoints: [String],
        representativeUnits: [NarrativeBriefUnit]
    ) -> [NarrativeMaterialSection] {
        var sections: [NarrativeMaterialSection] = []

        if !themes.isEmpty {
            sections.append(
                NarrativeMaterialSection(
                    id: UUID(),
                    title: "主要主题",
                    bullets: themes
                )
            )
        }

        if !changeSignals.isEmpty {
            sections.append(
                NarrativeMaterialSection(
                    id: UUID(),
                    title: "明显变化",
                    bullets: changeSignals
                )
            )
        }

        if !repeatedPatterns.isEmpty {
            sections.append(
                NarrativeMaterialSection(
                    id: UUID(),
                    title: "重复模式",
                    bullets: repeatedPatterns
                )
            )
        }

        if !turningPoints.isEmpty {
            sections.append(
                NarrativeMaterialSection(
                    id: UUID(),
                    title: "关键转折",
                    bullets: turningPoints
                )
            )
        }

        let representativeBullets = representativeUnits.prefix(4).map { unit in
            var parts = [unit.summary]
            if let firstResult = unit.resultOrState.first {
                parts.append("结果：\(firstResult)")
            }
            return parts.joined(separator: "｜")
        }
        if !representativeBullets.isEmpty {
            sections.append(
                NarrativeMaterialSection(
                    id: UUID(),
                    title: "代表性片段",
                    bullets: representativeBullets
                )
            )
        }

        return sections
    }
}
