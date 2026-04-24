import CoreData
import SwiftUI

struct ReviewHomeScreen: View {
    @Environment(\.managedObjectContext) private var context
    @State private var snippets: [ReviewHomeSnippet] = []
    @State private var hasData = false
    @State private var visibleTagCounts: [TagType: Int] = [:]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        NavigationLink("回看本周") {
                            WeeklyReviewScreen()
                        }
                        .buttonStyle(.bordered)

                        NavigationLink("回看本月") {
                            MonthlyReviewScreen()
                        }
                        .buttonStyle(.bordered)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("按线索回看")
                                .font(.headline)
                            Spacer()
                            NavigationLink("标签库") {
                                TagManagerScreen()
                            }
                            .font(.subheadline.weight(.semibold))
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(TagType.allCases) { tagType in
                                NavigationLink {
                                    ReviewByTagPickerScreen(tagType: tagType)
                                } label: {
                                    TagReviewEntryCard(
                                        title: "\(tagType.title)线索",
                                        subtitle: tagReviewSubtitle(for: tagType),
                                        count: visibleTagCounts[tagType] ?? 0
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !snippets.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("记忆片段")
                                .font(.headline)

                            ForEach(snippets) { snippet in
                                NavigationLink {
                                    SearchScreen(initialQuery: snippet.detail)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(snippet.title)
                                            .font(.subheadline.weight(.semibold))
                                        Text(snippet.detail)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !hasData {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("还没有可回顾内容。先记录几条，晚上回来看看。")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("回顾")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        TagManagerScreen()
                    } label: {
                        Image(systemName: "tag")
                    }

                    NavigationLink {
                        SearchScreen()
                    } label: {
                        Image(systemName: "sparkles")
                    }
                }
            }
            .onAppear {
                loadSnippets()
                loadVisibleTagCounts()
            }
        }
    }

    private func loadSnippets() {
        let recentCaptures = fetchRecentCaptures(daysBack: 7)
        hasData = !recentCaptures.isEmpty

        var result: [ReviewHomeSnippet] = []
        let tagNames = fetchTopTagNames(limit: 3)
        if !tagNames.isEmpty {
            result.append(
                ReviewHomeSnippet(
                    id: UUID(),
                    title: "你最近常提到",
                    detail: tagNames.joined(separator: "、")
                )
            )
        }

        let keyNodes = recentCaptures.prefix(3).map { $0.cleanText ?? $0.rawText }
        if !keyNodes.isEmpty {
            result.append(
                ReviewHomeSnippet(
                    id: UUID(),
                    title: "最近的几个关键节点",
                    detail: keyNodes.joined(separator: " / ")
                )
            )
        }

        snippets = result
    }

    private func loadVisibleTagCounts() {
        visibleTagCounts = Dictionary(uniqueKeysWithValues: TagType.allCases.map { type in
            let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
            request.predicate = NSPredicate(format: "isUserVisible == YES AND type == %@", type.rawValue)
            let count = (try? context.count(for: request)) ?? 0
            return (type, count)
        })
    }

    private func fetchRecentCaptures(daysBack: Int) -> [CaptureEntity] {
        let calendar = Calendar.current
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -daysBack, to: end) ?? end

        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            start as CVarArg,
            end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func fetchTopTagNames(limit: Int) -> [String] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let tags = (try? context.fetch(request)) ?? []
        return tags.prefix(limit).map { $0.name }
    }

    private func tagReviewSubtitle(for tagType: TagType) -> String {
        let count = visibleTagCounts[tagType] ?? 0
        if count > 0 {
            return "\(count) 个可回顾标签"
        }

        switch tagType {
        case .project:
            return "按长期线索整理回看"
        case .habit:
            return "按行为模式看变化"
        case .theme:
            return "按主题聚合记录"
        case .person:
            return "按人物整理互动"
        case .goal:
            return "按目标追踪进展"
        case .context:
            return "按场景回看生活"
        }
    }
}

private struct ReviewHomeSnippet: Identifiable {
    let id: UUID
    let title: String
    let detail: String
}

private struct TagReviewEntryCard: View {
    let title: String
    let subtitle: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
            if count > 0 {
                Text("\(count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
