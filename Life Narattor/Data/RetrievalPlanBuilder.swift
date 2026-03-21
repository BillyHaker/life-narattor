import Foundation

struct RetrievalPlanBuilder {
    let tagLibrary: TagLibrary
    let now: Date

    init(tagLibrary: TagLibrary, now: Date = Date()) {
        self.tagLibrary = tagLibrary
        self.now = now
    }

    func build(query: String, timeRangeOverride: RetrievalTimeRange? = nil) -> RetrievalPlan {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let explicitMatches = matchedFilters(in: normalized, includeAllTypes: true)
        let mode = inferredMode(for: normalized, explicitMatches: explicitMatches)
        let shape = inferredQuestionShape(for: normalized)
        let timeRange = timeRangeOverride ?? inferredTimeRange(for: normalized)
        let focusAnchor = inferredFocusAnchor(for: normalized, shape: shape)
        let relationAnchors = inferredRelationAnchors(for: normalized, shape: shape)
        let primary = makePrimaryFilters(query: normalized, explicitMatches: explicitMatches, shape: shape)
        let secondary = inferredSecondaryFilters(from: primary, shape: shape)

        return RetrievalPlan(
            mode: mode,
            questionShape: shape,
            query: normalized,
            timeRange: timeRange,
            focusAnchor: focusAnchor,
            relationAnchors: relationAnchors,
            primaryFilters: primary,
            secondaryFilters: secondary,
            tagScopeWeights: mode == .overview ? .overviewDefault : .focusedDefault,
            rankingWeights: mode == .overview ? .overviewDefault : .focusedDefault,
            compressionPolicy: compressionPolicy(for: mode, shape: shape)
        )
    }

    private func inferredMode(for query: String, explicitMatches: [(type: TagType, name: String)]) -> RetrievalMode {
        if !explicitMatches.isEmpty {
            return .focused
        }
        if inferredQuestionShape(for: query) == .openReview {
            return .overview
        }
        return .focused
    }

    private func inferredQuestionShape(for query: String) -> ReviewQuestionShape {
        if isBroadOpenReviewQuery(query) {
            return .openReview
        }
        if query.contains("项目") {
            return .projectReview
        }
        if query.contains("人物") || query.contains("老板") || query.contains("同事") || query.contains("家人") || query.contains("朋友") {
            return .personReview
        }
        if query.contains("场景") || query.contains("在公司") || query.contains("在家") || query.contains("通勤") || query.contains("晨间") || query.contains("晚上") {
            return .contextReview
        }
        if query.contains("关系") || query.contains("有没有关系") || query.contains("相关") {
            return .relation
        }
        if query.contains("前后") || query.contains("对比") {
            return .comparison
        }
        if query.contains("变化"), inferredComparisonAnchor(in: query) != nil {
            return .comparison
        }
        if query.contains("习惯") || query.contains("总是") || query.contains("经常") {
            return .patternReview
        }
        if query.contains("主题") || query.contains("情绪") || query.contains("状态") || query.contains("英语") {
            return .themeReview
        }
        return .openReview
    }

    private func isBroadOpenReviewQuery(_ query: String) -> Bool {
        let hasBroadTimeWindow =
            query.contains("过去一周") ||
            query.contains("最近一周") ||
            query.contains("过去一个月") ||
            query.contains("最近一个月") ||
            query.contains("过去三个月") ||
            query.contains("最近三个月") ||
            query.contains("本周") ||
            query.contains("本月") ||
            query.contains("这个月")

        let hasOverviewIntent =
            query.contains("都干了什么") ||
            query.contains("发生了什么") ||
            query.contains("主要") ||
            query.contains("有什么变化") ||
            query.contains("哪些变化") ||
            query.contains("最近怎么样")

        return hasBroadTimeWindow && hasOverviewIntent
    }

    private func inferredTimeRange(for query: String) -> RetrievalTimeRange {
        let calendar = Calendar.current
        let end = now

        if query.contains("过去一个月") || query.contains("最近一个月") {
            let start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
            return RetrievalTimeRange(start: start, end: end, label: "最近30天")
        }
        if query.contains("过去一周") || query.contains("最近一周") {
            let start = calendar.date(byAdding: .day, value: -7, to: end) ?? end
            return RetrievalTimeRange(start: start, end: end, label: "最近7天")
        }
        if query.contains("过去三个月") || query.contains("最近三个月") || query.contains("季度") {
            let start = calendar.date(byAdding: .day, value: -90, to: end) ?? end
            return RetrievalTimeRange(start: start, end: end, label: "最近90天")
        }

        let start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
        return RetrievalTimeRange(start: start, end: end, label: "最近30天")
    }

    private func matchedFilters(in query: String, includeAllTypes: Bool) -> [(type: TagType, name: String)] {
        let lowercased = query.lowercased()
        let library: [(TagType, [String])] = [
            (.project, tagLibrary.project),
            (.habit, tagLibrary.habit),
            (.theme, tagLibrary.theme),
            (.person, tagLibrary.person),
            (.goal, tagLibrary.goal),
            (.context, tagLibrary.context)
        ]

        return library.flatMap { type, names in
            names.compactMap { name in
                let match = lowercased.contains(name.lowercased())
                guard match else { return nil }
                return (type, name)
            }
        }
    }

    private func makePrimaryFilters(
        query: String,
        explicitMatches: [(type: TagType, name: String)],
        shape: ReviewQuestionShape
    ) -> [RetrievalTagFilter] {
        if !explicitMatches.isEmpty {
            return explicitMatches.map {
                RetrievalTagFilter(type: $0.type, name: $0.name, strength: 1.0, source: .explicit)
            }
        }

        let inferred = inferredPrimaryFilters(from: query, shape: shape)
        if !inferred.isEmpty {
            return inferred
        }

        return []
    }

    private func inferredPrimaryFilters(from query: String, shape: ReviewQuestionShape) -> [RetrievalTagFilter] {
        var filters: [RetrievalTagFilter] = []

        if query.contains("工作") || query.contains("上班") || query.contains("开会") || query.contains("岗位") {
            if let filter = existingFilter(type: .theme, name: "工作安排", strength: shape == .openReview ? 0.5 : 0.9) {
                filters.append(filter)
            }
        }
        if query.contains("情绪") || query.contains("心情") || query.contains("状态") {
            if let filter = existingFilter(type: .theme, name: "情绪波动", strength: 0.9) {
                filters.append(filter)
            }
        }
        if query.contains("英语") || query.contains("发音") || query.contains("口语") {
            if let filter = existingFilter(type: .project, name: "英语口语", strength: 0.9) {
                filters.append(filter)
            } else if let filter = existingFilter(type: .theme, name: "发音训练", strength: 0.9) {
                filters.append(filter)
            }
        }
        if query.contains("睡") || query.contains("作息") {
            if let filter = existingFilter(type: .theme, name: "睡眠", strength: 0.8) {
                filters.append(filter)
            }
        }
        if query.contains("吃") || query.contains("胃口") || query.contains("饮食") {
            if let filter = existingFilter(type: .theme, name: "饮食", strength: 0.8) {
                filters.append(filter)
            }
        }
        if query.contains("拖延") || query.contains("专注") || query.contains("执行") {
            if let filter = existingFilter(type: .theme, name: "执行力", strength: 0.8) {
                filters.append(filter)
            }
        }

        return uniqued(filters)
    }

    private func inferredSecondaryFilters(from primary: [RetrievalTagFilter], shape: ReviewQuestionShape) -> [RetrievalTagFilter] {
        guard let first = primary.first else { return [] }

        switch shape {
        case .projectReview:
            return [
                RetrievalTagFilter(type: .goal, name: "改善工作状态", strength: 0.6, source: .inferred),
                RetrievalTagFilter(type: .theme, name: "工作安排", strength: 0.7, source: .inferred)
            ]
        case .patternReview:
            return [
                RetrievalTagFilter(type: .habit, name: first.name, strength: 0.8, source: .inferred),
                RetrievalTagFilter(type: .context, name: "晨间", strength: 0.4, source: .inferred)
            ]
        case .personReview:
            return [
                RetrievalTagFilter(type: .theme, name: "工作安排", strength: 0.5, source: .inferred)
            ]
        case .openReview:
            return []
        default:
            return []
        }
    }

    func makeOpenReviewPlan(periodLabel: String, range: RetrievalTimeRange) -> RetrievalPlan {
        build(query: "我\(periodLabel)都干了什么，有什么主要变化", timeRangeOverride: range)
    }

    private func inferredFocusAnchor(for query: String, shape: ReviewQuestionShape) -> String? {
        switch shape {
        case .comparison:
            return inferredComparisonAnchor(in: query)
        case .relation:
            let anchors = inferredRelationAnchors(for: query, shape: shape)
            return anchors.first
        default:
            return nil
        }
    }

    private func inferredComparisonAnchor(in query: String) -> String? {
        extractAnchor(in: query, marker: "前后")
            ?? extractAnchor(in: query, marker: "对比")
            ?? extractAnchor(in: query, marker: "变化")
    }

    private func inferredRelationAnchors(for query: String, shape: ReviewQuestionShape) -> [String] {
        guard shape == .relation else { return [] }

        if query.contains("有没有关系"), let parts = splitRelationQuery(query, separator: "有没有关系") {
            return parts
        }
        if query.contains("有关系"), let parts = splitRelationQuery(query, separator: "有关系") {
            return parts
        }
        if query.contains("相关"), let parts = splitRelationQuery(query, separator: "相关") {
            return parts
        }
        return []
    }

    private func extractAnchor(in query: String, marker: String) -> String? {
        guard let range = query.range(of: marker) else { return nil }
        let prefix = query[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prefix.isEmpty else { return nil }
        let separators = CharacterSet(charactersIn: "，。！？；：,? ")
        let components = prefix.components(separatedBy: separators).filter { !$0.isEmpty }
        guard let candidate = components.last, candidate.count >= 2 else { return nil }
        return candidate
    }

    private func splitRelationQuery(_ query: String, separator: String) -> [String]? {
        let parts = query.components(separatedBy: separator)
        guard parts.count >= 2 else { return nil }
        let left = sanitizeAnchor(parts[0])
        let right = sanitizeAnchor(parts[1])
        let anchors = [left, right].compactMap { $0 }
        return anchors.count >= 2 ? anchors : nil
    }

    private func sanitizeAnchor(_ raw: String) -> String? {
        let stripped = raw
            .replacingOccurrences(of: "跟", with: " ")
            .replacingOccurrences(of: "和", with: " ")
            .replacingOccurrences(of: "我想看一下", with: " ")
            .replacingOccurrences(of: "我想知道", with: " ")
            .replacingOccurrences(of: "最近", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let separators = CharacterSet(charactersIn: "，。！？；：,? ")
        let components = stripped.components(separatedBy: separators).filter { !$0.isEmpty }
        guard let candidate = components.last, candidate.count >= 2 else { return nil }
        return candidate
    }

    private func compressionPolicy(for mode: RetrievalMode, shape: ReviewQuestionShape) -> RetrievalCompressionPolicy {
        switch mode {
        case .overview:
            return RetrievalCompressionPolicy(
                maxCaptures: 18,
                maxUnitsPerTheme: 2,
                preferCoverage: true,
                preferEvidenceDensity: false,
                preferTurningPoints: true
            )
        case .focused:
            return RetrievalCompressionPolicy(
                maxCaptures: shape == .relation || shape == .comparison ? 20 : 12,
                maxUnitsPerTheme: 3,
                preferCoverage: false,
                preferEvidenceDensity: true,
                preferTurningPoints: shape == .comparison
            )
        }
    }

    private func existingFilter(type: TagType, name: String, strength: Double) -> RetrievalTagFilter? {
        guard names(for: type).contains(name) else { return nil }
        return RetrievalTagFilter(type: type, name: name, strength: strength, source: .inferred)
    }

    private func names(for type: TagType) -> [String] {
        switch type {
        case .project: return tagLibrary.project
        case .habit: return tagLibrary.habit
        case .theme: return tagLibrary.theme
        case .person: return tagLibrary.person
        case .goal: return tagLibrary.goal
        case .context: return tagLibrary.context
        }
    }

    private func uniqued(_ filters: [RetrievalTagFilter]) -> [RetrievalTagFilter] {
        var seen: Set<String> = []
        return filters.filter { filter in
            let key = "\(filter.type.rawValue):\(filter.name)"
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
    }
}
