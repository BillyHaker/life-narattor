import CoreData
import SwiftUI

struct SearchScreen: View {
    @Environment(\.managedObjectContext) private var context

    @State private var query: String
    @State private var selectedFilter: SearchFilterType? = nil
    @State private var selectedDateRange: SearchDateRange = .all
    @State private var isSearching = false
    @State private var errorMessage: String? = nil
    @State private var results: [SearchResultItem] = []
    @State private var selectedCapture: CaptureItem? = nil
    @State private var selectedAtom: AtomItem? = nil
    @State private var isUsingRetrievalPlan = false
    @State private var activeRetrievalPlan: RetrievalPlan? = nil
    @State private var focusedEvidence: FocusedEvidenceBundle? = nil
    @State private var focusedEvidenceText: String? = nil
    @State private var expandedEvidenceGroupIDs: Set<UUID> = []
    @State private var focusedAIAnalysis: String? = nil
    @State private var isLoadingFocusedAIAnalysis = false
    @State private var overviewNarrativeMaterial: NarrativeMaterial? = nil
    @State private var overviewAIAnalysis: String? = nil
    @State private var isLoadingOverviewAIAnalysis = false
    @State private var followupInput: String = ""
    @State private var followupMessages: [ReviewFollowupMessage] = []
    @State private var isLoadingFollowup = false
    @State private var showAllFollowups = false
    @State private var suppressQueryReset = false
    @State private var expandedReviewSectionIDs: Set<String> = []
    @State private var clueSuggestions: [ReviewClueSuggestion] = []

    init(initialQuery: String = "", initialFilter: SearchFilterType? = nil) {
        _query = State(initialValue: initialQuery)
        _selectedFilter = State(initialValue: initialFilter)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchBar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    filterToolbar
                    resultsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("AI 回顾")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCapture) { item in
            CaptureDetailSheet(item: item, context: context)
        }
        .sheet(item: $selectedAtom) { atom in
            AtomDetailSheet(atom: atom, context: context, onSaved: {
                if shouldAutoRefreshAIReview {
                    performRetrievalSearch()
                }
            })
        }
        .navigationDestination(for: TimelineDay.self) { day in
            DayDetailScreen(day: day)
        }
        .onChange(of: query) { _, _ in
            if suppressQueryReset {
                suppressQueryReset = false
                return
            }
            resetAIReviewOutput()
        }
        .onChange(of: selectedFilter) { _, _ in
            if shouldAutoRefreshAIReview {
                performRetrievalSearch()
            }
        }
        .onChange(of: selectedDateRange) { _, _ in
            if shouldAutoRefreshAIReview {
                performRetrievalSearch()
            }
        }
        .onAppear {
            loadClueSuggestions()
            if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isUsingRetrievalPlan {
                performRetrievalSearch()
            }
        }
    }

    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("想从最近的记录里看见什么？")
                .font(.headline.weight(.semibold))
            Text("可以直接问，也可以从系统发现的线索开始。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.secondary)
                TextField("例如：我最近为什么总是卡住？", text: $query)
                    .submitLabel(.search)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performRetrievalSearch()
                    }
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                Button("开始回顾") {
                    performRetrievalSearch()
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 16)
    }

    private var filterToolbar: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(SearchDateRange.allCases) { range in
                    Button(range.title) {
                        selectedDateRange = range
                    }
                }
            } label: {
                filterPill(
                    title: selectedDateRange == .all ? "时间" : selectedDateRange.title,
                    systemImage: "calendar"
                )
            }
            .buttonStyle(.plain)

            Menu {
                Button("全部线索") {
                    selectedFilter = nil
                }
                ForEach(SearchFilterType.allCases.filter { $0 != .dateRange }) { filter in
                    Button(filter.title) {
                        selectedFilter = selectedFilter == filter ? nil : filter
                    }
                }
            } label: {
                filterPill(
                    title: selectedFilter?.title ?? "线索",
                    systemImage: "tag"
                )
            }
            .buttonStyle(.plain)

            if selectedFilter != nil || selectedDateRange != .all {
                Button("清除") {
                    selectedFilter = nil
                    selectedDateRange = .all
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isSearching {
                reviewStatusCard(text: "正在从记录里找线索…")
            } else if let plan = activeRetrievalPlan, plan.mode == .overview {
                VStack(alignment: .leading, spacing: 12) {
                    if isLoadingOverviewAIAnalysis {
                        reviewStatusCard(text: "正在整理这段时间的主要变化…")
                    } else if let overviewAIAnalysis, !overviewAIAnalysis.isEmpty {
                        reviewSectionCard(title: "事实与联系", accent: "先看事实") {
                            reviewAnalysisContent(overviewAIAnalysis)
                        }
                    }

                    if !results.isEmpty {
                        relatedRecordsCard
                    }
                }
            } else if let focusedEvidence, let focusedEvidenceText, shouldShowFocusedEvidence(for: focusedEvidence) {
                VStack(alignment: .leading, spacing: 12) {
                    if isLoadingFocusedAIAnalysis {
                        reviewStatusCard(text: "AI 正在分析证据…")
                    } else if let focusedAIAnalysis, !focusedAIAnalysis.isEmpty {
                        reviewSectionCard(title: "事实与联系", accent: "先看事实") {
                            reviewAnalysisContent(focusedAIAnalysis)
                        }
                    }

                    reviewSectionCard(title: "证据整理", accent: "依据") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(focusedEvidenceText)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            if !focusedEvidence.topSignals.isEmpty {
                                compactSignalRow(signals: Array(focusedEvidence.topSignals.prefix(4)))
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(focusedEvidence.evidenceGroups.prefix(3)) { group in
                                    DisclosureGroup(
                                        isExpanded: Binding(
                                            get: { expandedEvidenceGroupIDs.contains(group.id) },
                                            set: { isExpanded in
                                                if isExpanded {
                                                    expandedEvidenceGroupIDs.insert(group.id)
                                                } else {
                                                    expandedEvidenceGroupIDs.remove(group.id)
                                                }
                                            }
                                        )
                                    ) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(group.rationale)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                            ForEach(Array(group.units.prefix(3))) { unit in
                                                Text("• \(unit.summary)")
                                                    .font(.footnote)
                                                    .foregroundStyle(.primary)
                                            }
                                        }
                                        .padding(.top, 6)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(group.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            Text(group.units.prefix(2).map(\.summary).joined(separator: "；"))
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else if let errorMessage, !errorMessage.isEmpty {
                reviewSectionCard(title: "回顾结果", accent: "提示") {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if results.isEmpty, shouldShowEmptyState {
                reviewSectionCard(title: "没有足够的回顾材料", accent: "空") {
                    Text("试试换个说法，或只看某段时间、某条线索。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if !results.isEmpty {
                relatedRecordsCard
            } else if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if !clueSuggestions.isEmpty {
                    clueInspirationSection
                }

                reviewSectionCard(title: "试着这样问", accent: "示例") {
                    VStack(alignment: .leading, spacing: 8) {
                        starterPrompt("最近有什么事情反复出现")
                        starterPrompt("我最近为什么总是卡住")
                        starterPrompt("哪条线索最值得继续看")
                    }
                }
            }
        }
    }

    private var clueInspirationSection: some View {
        reviewSectionCard(title: "从这些线索开始", accent: "来自记录") {
            VStack(alignment: .leading, spacing: 12) {
                Text("这些是近期记录里沉淀出的主题。点开后，会直接围绕这条线索开始回顾。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                    ForEach(clueSuggestions) { clue in
                        Button {
                            submitCluePrompt(clue)
                        } label: {
                            ReviewClueSuggestionCard(clue: clue)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var groupedResults: [(date: Date, items: [SearchResultItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: results) { item in
            calendar.startOfDay(for: item.date)
        }

        return grouped
            .map { (date: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    private var shouldShowEmptyState: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedFilter != nil || selectedDateRange != .all
    }

    private var relatedRecordsCard: some View {
        reviewSectionCard(title: "相关记录", accent: "\(results.count)条") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(groupedResults, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        if let day = dayForGroup(group) {
                            NavigationLink(value: day) {
                                Text(formattedSectionDate(group.date))
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text(formattedSectionDate(group.date))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(group.items) { result in
                            SearchResultCard(result: result, onTagTap: { tag in
                                query = tag
                            }, onSelect: {
                                handleSelection(result)
                            })
                        }
                    }
                }
            }
        }
    }

    private var shouldAutoRefreshAIReview: Bool {
        isUsingRetrievalPlan && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func handleSelection(_ result: SearchResultItem) {
        switch result.source {
        case .capture(let item):
            selectedCapture = item
        case .atom(let atom):
            selectedAtom = atom
        }
    }

    private func dayForGroup(_ group: (date: Date, items: [SearchResultItem])) -> TimelineDay? {
        guard !group.items.isEmpty else { return nil }
        let snippets = group.items.map(\.snippet)
        let captureIDs = group.items.compactMap { item in
            switch item.source {
            case .capture(let capture):
                return capture.id
            case .atom(let atom):
                return atom.captureID
            }
        }
        let primaryLine = snippets.first ?? "这一天留下了一些片段。"
        let secondaryLines = Array(snippets.dropFirst().prefix(2))
        return TimelineDay(
            id: UUID(),
            date: group.date,
            recordCount: group.items.count,
            dayParts: [],
            primaryLine: primaryLine,
            secondaryLines: secondaryLines,
            highlightCaptureIDs: Array(captureIDs.dropFirst().prefix(2)),
            hasGeneratedNarrative: false
        )
    }

    private func performRetrievalSearch() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            resetAIReviewOutput()
            return
        }

        isUsingRetrievalPlan = true
        isSearching = true
        errorMessage = nil
        focusedEvidence = nil
        focusedEvidenceText = nil
        expandedEvidenceGroupIDs = []
        focusedAIAnalysis = nil
        isLoadingFocusedAIAnalysis = false
        overviewNarrativeMaterial = nil
        overviewAIAnalysis = nil
        isLoadingOverviewAIAnalysis = false
        followupInput = ""
        followupMessages = []
        isLoadingFollowup = false
        showAllFollowups = false
        expandedReviewSectionIDs = []

        let builder = RetrievalPlanBuilder(tagLibrary: loadVisibleTagLibrary())
        var plan = builder.build(query: trimmedQuery, timeRangeOverride: selectedDateRange.retrievalTimeRange)

        if let selectedFilter, let tagType = selectedFilter.tagType {
            let selectedMatches = fetchVisibleTagNames(type: tagType)
                .filter { name in
                    trimmedQuery.localizedCaseInsensitiveContains(name) || name.localizedCaseInsensitiveContains(trimmedQuery)
                }
                .map { name in
                    RetrievalTagFilter(type: tagType, name: name, strength: 1.2, source: .explicit)
                }

            plan = RetrievalPlan(
                mode: plan.mode,
                questionShape: plan.questionShape,
                query: plan.query,
                timeRange: plan.timeRange,
                focusAnchor: plan.focusAnchor,
                relationAnchors: plan.relationAnchors,
                primaryFilters: selectedMatches.isEmpty ? plan.primaryFilters : selectedMatches,
                secondaryFilters: plan.secondaryFilters,
                tagScopeWeights: plan.tagScopeWeights,
                rankingWeights: plan.rankingWeights,
                compressionPolicy: plan.compressionPolicy
            )
        }

        activeRetrievalPlan = plan
        let service = ReviewRetrievalService(context: context)
        if plan.mode == .focused {
            let evidence = service.makeFocusedEvidence(query: trimmedQuery, timeRangeOverride: selectedDateRange.retrievalTimeRange)
            if shouldShowFocusedEvidence(for: evidence) {
                focusedEvidence = evidence
                focusedEvidenceText = service.makeFocusedEvidenceText(from: evidence)
                expandedEvidenceGroupIDs = []
                requestFocusedAIAnalysis(for: evidence, followupQuestion: nil)
            }
        } else {
            let brief = MemoryIndexStore(context: context).buildNarrativeBrief(plan: plan)
            let material = service.makeNarrativeMaterial(from: brief)
            if !material.representativeUnits.isEmpty {
                overviewNarrativeMaterial = material
                requestOverviewAIAnalysis(for: material, label: plan.timeRange.label, followupQuestion: nil)
            }
        }
        let snapshots = MemoryIndexStore(context: context).search(plan: plan)
        results = snapshots.compactMap { makeRetrievalResult(from: $0, plan: plan) }
        if results.isEmpty {
            errorMessage = "没有找到足够相关的记录，可以换个问法、时间范围或线索再试。"
        }
        isSearching = false
    }

    private func resetAIReviewOutput() {
        isUsingRetrievalPlan = false
        activeRetrievalPlan = nil
        errorMessage = nil
        results = []
        focusedEvidence = nil
        focusedEvidenceText = nil
        expandedEvidenceGroupIDs = []
        focusedAIAnalysis = nil
        isLoadingFocusedAIAnalysis = false
        overviewNarrativeMaterial = nil
        overviewAIAnalysis = nil
        isLoadingOverviewAIAnalysis = false
        followupInput = ""
        followupMessages = []
        isLoadingFollowup = false
        showAllFollowups = false
        expandedReviewSectionIDs = []
    }

    private func matchesFilter(_ item: SearchResultItem) -> Bool {
        guard let selectedFilter, let requiredType = selectedFilter.tagType else { return true }

        switch item.source {
        case .atom(let atom):
            return atom.tags.contains { $0.type == requiredType }
        case .capture:
            return false
        }
    }

    private func shouldShowFocusedEvidence(for bundle: FocusedEvidenceBundle) -> Bool {
        bundle.plan.mode == .focused && !bundle.evidenceGroups.isEmpty
    }

    private func requestFocusedAIAnalysis(for bundle: FocusedEvidenceBundle, followupQuestion: String?) {
        if followupQuestion == nil {
            isLoadingFocusedAIAnalysis = true
            focusedAIAnalysis = nil
        } else {
            isLoadingFollowup = true
        }
        Task {
            do {
                let analysis = try await AIServiceFactory.make().analyzeFocusedEvidence(bundle, followupQuestion: followupQuestion)
                await MainActor.run {
                    let normalized = analysis.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let followupQuestion {
                        followupMessages.append(ReviewFollowupMessage(question: followupQuestion, answer: normalized))
                        followupInput = ""
                        isLoadingFollowup = false
                        showAllFollowups = false
                    } else {
                        focusedAIAnalysis = normalized
                        isLoadingFocusedAIAnalysis = false
                    }
                }
            } catch {
                await MainActor.run {
                    if followupQuestion == nil {
                        focusedAIAnalysis = nil
                        isLoadingFocusedAIAnalysis = false
                    } else {
                        isLoadingFollowup = false
                    }
                }
            }
        }
    }

    private func requestOverviewAIAnalysis(for material: NarrativeMaterial, label: String, followupQuestion: String?) {
        if followupQuestion == nil {
            isLoadingOverviewAIAnalysis = true
            overviewAIAnalysis = nil
        } else {
            isLoadingFollowup = true
        }
        Task {
            do {
                let analysis = try await AIServiceFactory.make().analyzeNarrativeMaterial(material, periodName: label, followupQuestion: followupQuestion)
                await MainActor.run {
                    let normalized = analysis.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let followupQuestion {
                        followupMessages.append(ReviewFollowupMessage(question: followupQuestion, answer: normalized))
                        followupInput = ""
                        isLoadingFollowup = false
                        showAllFollowups = false
                    } else {
                        overviewAIAnalysis = normalized
                        isLoadingOverviewAIAnalysis = false
                    }
                }
            } catch {
                await MainActor.run {
                    if followupQuestion == nil {
                        overviewAIAnalysis = nil
                        isLoadingOverviewAIAnalysis = false
                    } else {
                        isLoadingFollowup = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func reviewAnalysisContent(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            reviewBubble(text: text, isUser: false)

            if !suggestedFollowups.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("可继续问")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestedFollowups, id: \.self) { item in
                                Button(item) {
                                    submitFollowup(item)
                                }
                                .font(.footnote)
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                }
            }

            if !followupMessages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if olderFollowupCount > 0 {
                        Button(showAllFollowups ? "收起较早追问" : "展开更早 \(olderFollowupCount) 轮") {
                            showAllFollowups.toggle()
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                    }

                    ForEach(displayedFollowupMessages) { message in
                        VStack(alignment: .leading, spacing: 8) {
                            reviewBubble(text: message.question, isUser: true)
                            reviewBubble(text: message.answer, isUser: false)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("继续追问")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    TextField("继续问这次回顾…", text: $followupInput)
                        .textFieldStyle(.roundedBorder)
                    Button("发送") {
                        submitFollowup(followupInput)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(followupInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingFollowup)
                }
                if isLoadingFollowup {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("正在结合这次回看的材料继续整理…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func reviewBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser {
                Spacer(minLength: 36)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Group {
                    let sections = parsedReviewSections(from: text)
                    if !sections.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(sections) { section in
                                reviewSectionBlock(section)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        Text(text)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                Spacer(minLength: 36)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func parsedReviewSections(from text: String) -> [ReviewSection] {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        let labels = ["事实：", "联系：", "可继续问："]
        guard labels.contains(where: { normalized.contains($0) }) else { return [] }

        var sections: [ReviewSection] = []
        let lines = normalized
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            if let label = labels.first(where: { line.hasPrefix($0) }) {
                let title = String(label.dropLast())
                let body = line.replacingOccurrences(of: label, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                sections.append(ReviewSection(title: title, body: body))
            } else if var last = sections.popLast() {
                last.body += "\n" + line
                sections.append(last)
            }
        }

        return sections
    }
    @ViewBuilder
    private func reviewSectionBlock(_ section: ReviewSection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(section.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            if section.title == "可继续问", let prompts = parsedPromptList(from: section.body), !prompts.isEmpty {
                followupPromptWrap(prompts)
            } else {
                let isExpanded = expandedReviewSectionIDs.contains(section.id)
                Text(section.body)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .lineLimit(shouldCollapseReviewSection(section) && !isExpanded ? 4 : nil)

                if shouldCollapseReviewSection(section) {
                    Button(isExpanded ? "收起" : "展开") {
                        if isExpanded {
                            expandedReviewSectionIDs.remove(section.id)
                        } else {
                            expandedReviewSectionIDs.insert(section.id)
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func shouldCollapseReviewSection(_ section: ReviewSection) -> Bool {
        section.body.count > 90 || section.body.split(separator: Character("\n")).count > 2
    }

    private func parsedPromptList(from text: String) -> [String]? {
        let normalized = text
            .replacingOccurrences(of: String(Character("\n")), with: " ")
            .replacingOccurrences(of: "？", with: "？|")
            .replacingOccurrences(of: "?", with: "?|")
        let prompts = normalized
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.hasSuffix("？") || $0.hasSuffix("?") ? $0 : $0 + "？" }
        return prompts.isEmpty ? nil : Array(prompts.prefix(3))
    }

    @ViewBuilder
    private func followupPromptWrap(_ prompts: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(prompts, id: \.self) { prompt in
                Button(prompt) {
                    submitFollowup(prompt)
                }
                .font(.footnote)
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .buttonStyle(.plain)
            }
        }
    }


    private var suggestedFollowups: [String] {
        guard let plan = activeRetrievalPlan else { return [] }
        switch plan.mode {
        case .overview:
            return overviewSuggestedFollowups(for: plan)
        case .focused:
            return focusedSuggestedFollowups(for: plan)
        }
    }

    private var displayedFollowupMessages: [ReviewFollowupMessage] {
        if showAllFollowups || followupMessages.count <= 2 {
            return followupMessages
        }
        return Array(followupMessages.suffix(2))
    }

    private var olderFollowupCount: Int {
        max(followupMessages.count - displayedFollowupMessages.count, 0)
    }

    private func overviewSuggestedFollowups(for plan: RetrievalPlan) -> [String] {
        var candidates: [String] = []

        if let material = overviewNarrativeMaterial {
            if let firstTheme = material.primaryThemes.first, firstTheme.count <= 12 {
                candidates.append("\(firstTheme)这条线最近有什么变化")
            }
            if material.primaryThemes.count >= 2 {
                let first = material.primaryThemes[0]
                let second = material.primaryThemes[1]
                if first.count <= 12, second.count <= 12 {
                    candidates.append("\(first)和\(second)之间有关系吗")
                }
            }
            if !material.changeSignals.isEmpty {
                candidates.append("哪条变化最值得继续看")
            }
            if let pattern = material.repeatedPatterns.first, pattern.count <= 18 {
                candidates.append("\(pattern)是不是这周反复出现")
            } else {
                candidates.append("这些变化和状态有没有关系")
            }
        }

        if candidates.isEmpty {
            candidates = [
                "这周最明显的变化是什么",
                "哪些线索最值得继续看",
                "这些变化和状态有没有关系"
            ]
        }

        return deduplicatedFollowups(candidates, limit: 3, excluding: plan.query)
    }

    private func focusedSuggestedFollowups(for plan: RetrievalPlan) -> [String] {
        var candidates: [String] = []

        switch plan.questionShape {
        case .comparison:
            if let anchor = plan.focusAnchor, anchor.count <= 14 {
                candidates.append("\(anchor)前后最明显的差别是什么")
                candidates.append("哪些记录最能说明\(anchor)前后的变化")
                candidates.append("还缺哪些和\(anchor)有关的记录")
            }
        case .relation:
            if plan.relationAnchors.count >= 2 {
                let first = plan.relationAnchors[0]
                let second = plan.relationAnchors[1]
                if first.count <= 12, second.count <= 12 {
                    candidates.append("\(first)和\(second)一起出现得多吗")
                    candidates.append("哪些记录最能说明\(first)和\(second)的关系")
                    candidates.append("如果只看最近记录，这种关系还明显吗")
                }
            }
        default:
            if let groupTitle = focusedEvidence?.evidenceGroups.first?.title {
                candidates.append("\(groupTitle)里最关键的证据是什么")
            }
            if let signal = focusedEvidence?.topSignals.first, signal.count <= 16 {
                candidates.append("\(signal)和当前问题的关系更强吗")
            }
            candidates.append("还缺什么证据")
        }

        if candidates.isEmpty {
            candidates = [
                "有哪些证据最支持这个判断",
                "前后对比最明显的地方是什么",
                "还缺什么证据"
            ]
        }

        return deduplicatedFollowups(candidates, limit: 3, excluding: plan.query)
    }

    private func deduplicatedFollowups(_ items: [String], limit: Int, excluding query: String) -> [String] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var seen: Set<String> = []
        return items
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter {
                !$0.isEmpty &&
                $0 != normalizedQuery &&
                seen.insert($0).inserted
            }
            .prefix(limit)
            .map { $0 }
    }

    private func submitFollowup(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoadingFollowup else { return }
        if let bundle = focusedEvidence, shouldShowFocusedEvidence(for: bundle) {
            requestFocusedAIAnalysis(for: bundle, followupQuestion: trimmed)
            return
        }
        if let material = overviewNarrativeMaterial, let plan = activeRetrievalPlan {
            requestOverviewAIAnalysis(for: material, label: plan.timeRange.label, followupQuestion: trimmed)
        }
    }

    private func fetchCaptures(matching query: String, datePredicate: NSPredicate?) -> [CaptureEntity] {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        var predicates: [NSPredicate] = []

        if !query.isEmpty {
            predicates.append(
                NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "rawText CONTAINS[cd] %@", query),
                    NSPredicate(format: "cleanText CONTAINS[cd] %@", query),
                    NSPredicate(format: "transcriptText CONTAINS[cd] %@", query)
                ])
            )
        }

        if let datePredicate {
            predicates.append(datePredicate)
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func fetchAtoms(matching query: String, datePredicate: NSPredicate?) -> [AtomEntity] {
        guard !query.isEmpty else { return [] }
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        var predicates: [NSPredicate] = [NSPredicate(format: "content CONTAINS[cd] %@", query)]

        if let datePredicate {
            predicates.append(datePredicate)
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func fetchAtoms(atomIDs: [UUID], datePredicate: NSPredicate?) -> [AtomEntity] {
        guard !atomIDs.isEmpty else { return [] }
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        var predicates: [NSPredicate] = [NSPredicate(format: "id IN %@", atomIDs)]

        if let datePredicate {
            predicates.append(datePredicate)
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func fetchTagIDs(matching query: String) -> [UUID] {
        if query.isEmpty, selectedFilter?.tagType == nil {
            return []
        }
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        var predicates: [NSPredicate] = []

        if !query.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", query))
        }

        if let selectedFilter, let type = selectedFilter.tagType {
            predicates.append(NSPredicate(format: "type == %@", type.rawValue))
        }
        predicates.append(NSPredicate(format: "isUserVisible == YES"))

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        return (try? context.fetch(request).map { $0.id }) ?? []
    }

    private func fetchAtomIDs(tagIDs: [UUID]) -> [UUID] {
        guard !tagIDs.isEmpty else { return [] }
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "tagID IN %@", tagIDs)
        return (try? context.fetch(request).map { $0.atomID }) ?? []
    }

    private func mergeAtoms(_ first: [AtomEntity], _ second: [AtomEntity]) -> [AtomEntity] {
        let merged = (first + second)
        var seen: Set<UUID> = []
        return merged.filter { atom in
            guard !seen.contains(atom.id) else { return false }
            seen.insert(atom.id)
            return true
        }
    }

    private func makeAtomItems(from atoms: [AtomEntity]) -> [AtomItem] {
        let atomIDs = atoms.map { $0.id }
        let tagMap = fetchTagMap(atomIDs: atomIDs)

        return atoms.map { atom in
            let startChar = atom.startChar >= 0 ? Int(atom.startChar) : nil
            let endChar = atom.endChar >= 0 ? Int(atom.endChar) : nil
            return AtomItem(
                id: atom.id,
                captureID: atom.captureID,
                type: AtomType(rawValue: atom.type) ?? .event,
                content: atom.content,
                orderInCapture: Int(atom.orderInCapture),
                isKey: atom.isKey,
                tags: tagMap[atom.id] ?? [],
                startChar: startChar,
                endChar: endChar,
                atomizeVersion: atom.atomizeVersion
            )
        }
    }

    private func fetchTagMap(atomIDs: [UUID]) -> [UUID: [TagItem]] {
        guard !atomIDs.isEmpty else { return [:] }

        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)

        guard let links = try? context.fetch(linkRequest) else { return [:] }
        let tagIDs = links.map { $0.tagID }
        let tagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        tagRequest.predicate = NSPredicate(format: "id IN %@ AND isUserVisible == YES", tagIDs)

        guard let tags = try? context.fetch(tagRequest) else { return [:] }

        let tagMap = Dictionary(uniqueKeysWithValues: tags.map { tag in
            (
                tag.id,
                TagItem(
                    id: tag.id,
                    name: tag.name,
                    type: TagType(rawValue: tag.type) ?? .project,
                    isCommon: tag.isCommon,
                    isSuggested: false,
                    isUserVisible: true
                )
            )
        })

        return links.reduce(into: [:]) { result, link in
            guard let tag = tagMap[link.tagID] else { return }
            result[link.atomID, default: []].append(tag)
        }
    }

    private func fetchVisibleTagNames(type: TagType) -> [String] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES AND type == %@", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return ((try? context.fetch(request)) ?? []).map(\.name)
    }

    private func loadClueSuggestions() {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES")
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let tags = (try? context.fetch(request)) ?? []
        let suggestions = tags.compactMap { tag -> ReviewClueSuggestion? in
            guard let type = TagType(rawValue: tag.type) else { return nil }
            let atomCount = fetchAtomCount(tagID: tag.id)
            guard atomCount > 0 else { return nil }
            return ReviewClueSuggestion(
                id: tag.id,
                name: tag.name,
                type: type,
                atomCount: atomCount,
                createdAt: tag.createdAt
            )
        }

        clueSuggestions = suggestions
            .sorted { lhs, rhs in
                if lhs.atomCount != rhs.atomCount {
                    return lhs.atomCount > rhs.atomCount
                }
                return lhs.createdAt > rhs.createdAt
            }
            .prefix(4)
            .map { $0 }
    }

    private func fetchAtomCount(tagID: UUID) -> Int {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "tagID == %@", tagID as CVarArg)
        return (try? context.count(for: request)) ?? 0
    }

    private func loadVisibleTagLibrary() -> TagLibrary {
        TagLibrary(
            project: fetchVisibleTagNames(type: .project),
            habit: fetchVisibleTagNames(type: .habit),
            theme: fetchVisibleTagNames(type: .theme),
            person: fetchVisibleTagNames(type: .person),
            goal: fetchVisibleTagNames(type: .goal),
            context: fetchVisibleTagNames(type: .context)
        )
    }

    private func makeRetrievalResult(from snapshot: IndexedCaptureSnapshot, plan: RetrievalPlan) -> SearchResultItem? {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", snapshot.id as CVarArg)
        guard let entity = try? context.fetch(request).first else { return nil }
        let item = makeCaptureItem(from: entity)
        let topUnit = snapshot.units.first?.summary ?? snapshot.cleanText
        let tags = Array(snapshot.visibleTags.map(\.name).prefix(3))
        return SearchResultItem(
            id: item.id,
            date: item.createdAt,
            timeText: formattedTime(item.createdAt),
            snippet: topUnit,
            tags: tags,
            hitReason: makeHitReason(for: snapshot, plan: plan),
            source: .capture(item)
        )
    }

    private func makeHitReason(for snapshot: IndexedCaptureSnapshot, plan: RetrievalPlan) -> String? {
        let visibleNames = Set(snapshot.visibleTags.map(\.name))
        let hiddenNames = Set(snapshot.hiddenTags.map(\.name))
        let hintNames = Set(snapshot.tagHints)

        let primaryVisible = plan.primaryFilters
            .filter { visibleNames.contains($0.name) }
            .map(\.name)
        if !primaryVisible.isEmpty {
            return "命中标签：\(primaryVisible.prefix(2).joined(separator: "、"))"
        }

        let primaryHidden = plan.primaryFilters
            .filter { hiddenNames.contains($0.name) || hintNames.contains($0.name) }
            .map(\.name)
        if !primaryHidden.isEmpty {
            return "命中隐性线索：\(primaryHidden.prefix(2).joined(separator: "、"))"
        }

        if let firstResult = snapshot.units.first?.resultOrState.first {
            return "关联结果：\(firstResult)"
        }

        if let firstTag = snapshot.visibleTags.first?.name {
            return "相关标签：\(firstTag)"
        }

        return activeRetrievalPlan?.mode == .overview ? "按近期变化召回" : "按相关性召回"
    }

    private func makeCaptureItem(from entity: CaptureEntity) -> CaptureItem {
        CaptureItem(
            id: entity.id,
            createdAt: entity.createdAt,
            rawText: entity.rawText,
            cleanText: entity.cleanText,
            ackTitle: entity.ackTitle,
            ackDetail: entity.ackDetail,
            dayPart: DayPart(rawValue: entity.dayPart ?? DayPart.morning.rawValue) ?? .morning,
            mode: CaptureInputMode(rawValue: entity.mode ?? CaptureInputMode.log.rawValue) ?? .log,
            assistRecord: nil,
            atomsCount: Int(entity.atomsCount),
            processingState: CaptureProcessingState(rawValue: entity.processingState ?? CaptureProcessingState.pendingClean.rawValue) ?? .pendingClean,
            inputType: CaptureInputType(rawValue: entity.inputType ?? CaptureInputType.text.rawValue) ?? .text,
            audioPath: entity.audioPath,
            transcriptText: entity.transcriptText,
            transcriptionStatus: TranscriptionStatus(rawValue: entity.transcriptionStatus ?? ""),
            transcriptionErrorReason: entity.transcriptionError,
            isTranscriptionActive: false
        )
    }

    private func atomDate(for atom: AtomItem, fallback: Date) -> Date {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", atom.captureID as CVarArg)
        return (try? context.fetch(request).first?.createdAt) ?? fallback
    }

    private func dateRangePredicate() -> NSPredicate? {
        guard let range = selectedDateRange.dateRange else { return nil }
        return NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", range.start as CVarArg, range.end as CVarArg)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formattedSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private func filterPill(title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
            Text(title)
                .font(.footnote.weight(.medium))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(Capsule())
    }

    private func reviewStatusCard(text: String) -> some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func reviewSectionCard<Content: View>(title: String, accent: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(accent)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func compactSignalRow(signals: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(signals, id: \.self) { signal in
                    Text(signal)
                        .font(.caption)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func starterPrompt(_ text: String) -> some View {
        Button {
            submitStarterPrompt(text)
        } label: {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func submitStarterPrompt(_ text: String) {
        suppressQueryReset = true
        query = text
        DispatchQueue.main.async {
            performRetrievalSearch()
        }
    }

    private func submitCluePrompt(_ clue: ReviewClueSuggestion) {
        selectedFilter = SearchFilterType.from(tagType: clue.type)
        selectedDateRange = .last90Days
        submitStarterPrompt("围绕「\(clue.name)」这条线索，最近有什么值得注意的变化？")
    }
}

private struct ReviewClueSuggestion: Identifiable {
    let id: UUID
    let name: String
    let type: TagType
    let atomCount: Int
    let createdAt: Date

    var display: ReviewClueDisplay {
        ReviewClueDisplay.make(name: name, type: type, atomCount: atomCount)
    }

    var typeTitle: String {
        type.title
    }
}

private struct ReviewClueDisplay {
    let iconName: String
    let tint: Color
    let subtitle: String

    static func make(name: String, type: TagType, atomCount: Int) -> ReviewClueDisplay {
        let matched = keywordDisplay(name: name)
        let fallback = fallbackDisplay(type: type)
        let label = matched?.label ?? fallback.label
        return ReviewClueDisplay(
            iconName: matched?.iconName ?? fallback.iconName,
            tint: matched?.tint ?? fallback.tint,
            subtitle: "\(label) · \(atomCount) 条片段可回看"
        )
    }

    private static func keywordDisplay(name: String) -> (iconName: String, tint: Color, label: String)? {
        if name.matchesAny(["工作", "任务", "安排", "会议", "通勤", "公司", "上班", "项目", "截止", "计划"]) {
            return ("calendar", .blue, "和计划、任务节奏有关")
        }
        if name.matchesAny(["早起", "晨间", "早晨", "上午", "起床", "启动", "开始"]) {
            return ("sun.max", .orange, "和一天开始后的状态有关")
        }
        if name.matchesAny(["睡眠", "睡觉", "熬夜", "失眠", "午睡", "休息"]) {
            return ("bed.double", .indigo, "和休息、恢复状态有关")
        }
        if name.matchesAny(["情绪", "心情", "焦虑", "紧张", "烦", "烦躁", "压力", "低落", "开心", "难受"]) {
            return ("heart.text.square", .pink, "和情绪起伏有关")
        }
        if name.matchesAny(["运动", "健身", "跑步", "训练", "肌酸", "蛋白", "补剂", "饮食", "胃口", "吃饭", "咖啡"]) {
            return ("figure.run", .green, "和身体状态、饮食或运动有关")
        }
        if name.matchesAny(["游戏", "段位", "云顶", "娱乐", "放松", "围棋", "象棋"]) {
            return ("gamecontroller", .purple, "和娱乐、投入感有关")
        }
        if name.matchesAny(["学习", "阅读", "课程", "英语", "写作", "思考", "复盘", "知识"]) {
            return ("book.closed", .teal, "和学习、输入输出有关")
        }
        if name.matchesAny(["朋友", "家人", "同事", "老板", "客户", "聊天", "关系", "沟通"]) {
            return ("person.2", .orange, "和人际互动有关")
        }
        return nil
    }

    private static func fallbackDisplay(type: TagType) -> (iconName: String, tint: Color, label: String) {
        switch type {
        case .project:
            return ("folder", .blue, "项目线索")
        case .habit:
            return ("repeat", .green, "习惯线索")
        case .theme:
            return ("sparkles", .purple, "主题线索")
        case .person:
            return ("person", .orange, "人物线索")
        case .goal:
            return ("target", .indigo, "目标线索")
        case .context:
            return ("mappin.and.ellipse", .teal, "场景线索")
        }
    }
}

private extension String {
    func matchesAny(_ keywords: [String]) -> Bool {
        keywords.contains { localizedCaseInsensitiveContains($0) }
    }
}

private struct ReviewClueSuggestionCard: View {
    let clue: ReviewClueSuggestion

    var body: some View {
        let display = clue.display
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(display.tint.opacity(0.10))
                    .frame(width: 38, height: 38)
                Image(systemName: display.iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(display.tint)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(clue.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(display.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(display.tint.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct SearchResultCard: View {
    let result: SearchResultItem
    let onTagTap: (String) -> Void
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(formattedDate(result.date)) · \(result.timeText)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(result.snippet)
                .font(.body)

            if !result.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(result.tags, id: \.self) { tag in
                        Button {
                            onTagTap(tag)
                        } label: {
                            Text(tag)
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if let hitReason = result.hitReason, !hitReason.isEmpty {
                Text(hitReason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .onTapGesture(perform: onSelect)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

private enum SearchDateRange: String, CaseIterable, Identifiable {
    case all
    case last7Days
    case last30Days
    case last90Days

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "全部"
        case .last7Days:
            return "最近7天"
        case .last30Days:
            return "最近30天"
        case .last90Days:
            return "最近90天"
        }
    }

    var dateRange: (start: Date, end: Date)? {
        guard self != .all else { return nil }
        let calendar = Calendar.current
        let end = Date()
        let start: Date

        switch self {
        case .all:
            return nil
        case .last7Days:
            start = calendar.date(byAdding: .day, value: -7, to: end) ?? end
        case .last30Days:
            start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
        case .last90Days:
            start = calendar.date(byAdding: .day, value: -90, to: end) ?? end
        }

        return (start: start, end: end)
    }

    var retrievalTimeRange: RetrievalTimeRange? {
        guard let range = dateRange else { return nil }
        return RetrievalTimeRange(start: range.start, end: range.end, label: title)
    }
}

private struct ReviewFollowupMessage: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

private struct ReviewSection: Identifiable {
    let title: String
    var body: String

    var id: String { "\(title)|\(body)" }
}
