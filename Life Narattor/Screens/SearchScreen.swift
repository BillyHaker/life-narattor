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
    @State private var showingDateRangePicker = false
    @State private var selectedCapture: CaptureItem? = nil
    @State private var selectedAtom: AtomItem? = nil

    private let recentSearches = ["方向乱", "项目", "运动"]

    init(initialQuery: String = "") {
        _query = State(initialValue: initialQuery)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            searchBar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    filterRow
                    recentSection
                    resultsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("搜索")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("选择时间范围", isPresented: $showingDateRangePicker, titleVisibility: .visible) {
            ForEach(SearchDateRange.allCases) { range in
                Button(range.title) {
                    selectedDateRange = range
                }
            }
        }
        .sheet(item: $selectedCapture) { item in
            CaptureDetailSheet(item: item, context: context)
        }
        .sheet(item: $selectedAtom) { atom in
            AtomDetailSheet(atom: atom, context: context, onSaved: performSearch)
        }
        .onAppear {
            performSearch()
        }
        .onChange(of: query) { _, _ in
            performSearch()
        }
        .onChange(of: selectedFilter) { _, _ in
            performSearch()
        }
        .onChange(of: selectedDateRange) { _, _ in
            performSearch()
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜一搜：比如“上次什么时候也觉得方向乱？"", text: $query)
                .textFieldStyle(.plain)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var filterRow: some View {
        HStack(spacing: 8) {
            ForEach(SearchFilterType.allCases) { filter in
                Button {
                    if filter == .dateRange {
                        showingDateRangePicker = true
                    } else {
                        selectedFilter = selectedFilter == filter ? nil : filter
                    }
                } label: {
                    Text(filterTitle(for: filter))
                        .font(.footnote)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(filterBackground(for: filter))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近搜索")
                .font(.headline)
            ForEach(recentSearches, id: \.self) { item in
                Button {
                    query = item
                } label: {
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isSearching {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("搜索中…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if results.isEmpty, shouldShowEmptyState {
                Text("没找到相关记录")
                    .font(.subheadline)
                Text("试试换个关键词／选择标签／扩大时间范围。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if !results.isEmpty {
                Text("结果")
                    .font(.headline)

                ForEach(groupedResults, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedSectionDate(group.date))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

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

    private func filterTitle(for filter: SearchFilterType) -> String {
        if filter == .dateRange {
            return selectedDateRange == .all ? filter.title : "日期范围·\(selectedDateRange.title)"
        }
        return filter.title
    }

    private func filterBackground(for filter: SearchFilterType) -> Color {
        if filter == selectedFilter {
            return Color(.systemGray4)
        }
        return Color(.systemGray6)
    }

    private func handleSelection(_ result: SearchResultItem) {
        switch result.source {
        case .capture(let item):
            selectedCapture = item
        case .atom(let atom):
            selectedAtom = atom
        }
    }

    private func performSearch() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil

        if trimmedQuery.isEmpty, selectedFilter == nil, selectedDateRange == .all {
            results = []
            return
        }

        isSearching = true

        let datePredicate = dateRangePredicate()
        do {
            let matchedTagIDs = fetchTagIDs(matching: trimmedQuery)
            let atomIDsFromTags = fetchAtomIDs(tagIDs: matchedTagIDs)
            let atomsFromContent = fetchAtoms(matching: trimmedQuery, datePredicate: datePredicate)
            let atomsFromTags = fetchAtoms(atomIDs: atomIDsFromTags, datePredicate: datePredicate)

            let atomEntities = mergeAtoms(atomsFromContent, atomsFromTags)
            let atomItems = makeAtomItems(from: atomEntities)

            let capturesFromContent = fetchCaptures(matching: trimmedQuery, datePredicate: datePredicate)
            let captureItems = capturesFromContent.map { makeCaptureItem(from: $0) }

            let captureResults = captureItems.map { item in
                SearchResultItem(
                    id: item.id,
                    date: item.createdAt,
                    timeText: formattedTime(item.createdAt),
                    snippet: item.cleanText ?? item.rawText,
                    tags: [],
                    source: .capture(item)
                )
            }

            let atomResults = atomItems.map { atom in
                SearchResultItem(
                    id: atom.id,
                    date: atomDate(for: atom, fallback: Date()),
                    timeText: formattedTime(atomDate(for: atom, fallback: Date())),
                    snippet: atom.content,
                    tags: atom.tags.map { $0.name },
                    source: .atom(atom)
                )
            }

            results = (captureResults + atomResults)
                .filter { item in
                    matchesFilter(item)
                }
                .sorted { $0.date > $1.date }
        } catch {
            errorMessage = "搜索不可用"
            results = []
        }

        isSearching = false
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
        guard !query.isEmpty else { return [] }
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        var predicates: [NSPredicate] = [NSPredicate(format: "name CONTAINS[cd] %@", query)]

        if let selectedFilter, let type = selectedFilter.tagType {
            predicates.append(NSPredicate(format: "type == %@", type.rawValue))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
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
            AtomItem(
                id: atom.id,
                captureID: atom.captureID,
                type: AtomType(rawValue: atom.type) ?? .event,
                content: atom.content,
                orderInCapture: Int(atom.orderInCapture),
                isKey: atom.isKey,
                tags: tagMap[atom.id] ?? []
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
        tagRequest.predicate = NSPredicate(format: "id IN %@", tagIDs)

        guard let tags = try? context.fetch(tagRequest) else { return [:] }

        let tagMap = Dictionary(uniqueKeysWithValues: tags.map { tag in
            (
                tag.id,
                TagItem(id: tag.id, name: tag.name, type: TagType(rawValue: tag.type) ?? .project, isCommon: tag.isCommon)
            )
        })

        return links.reduce(into: [:]) { result, link in
            guard let tag = tagMap[link.tagID] else { return }
            result[link.atomID, default: []].append(tag)
        }
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
            transcriptionStatus: TranscriptionStatus(rawValue: entity.transcriptionStatus ?? "")
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
}
