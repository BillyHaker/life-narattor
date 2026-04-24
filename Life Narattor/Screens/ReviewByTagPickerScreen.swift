import CoreData
import SwiftUI

struct ReviewByTagPickerScreen: View {
    let tagType: TagType

    @Environment(\.managedObjectContext) private var context
    @State private var tags: [TagRow] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if tags.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(tags) { tag in
                            NavigationLink {
                                SearchScreen(initialQuery: tag.name, initialFilter: SearchFilterType.from(tagType: tagType))
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tag.name)
                                        .font(.headline)
                                    if tag.isCommon {
                                        Text("常用")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(tagType.title)线索")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadTags)
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(emptyStateText)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var emptyStateText: String {
        switch tagType {
        case .project:
            return "还没有长期项目线索。之后记录多起来，这里会更适合回看。"
        case .habit:
            return "还没有习惯线索。先积累一些行为片段。"
        case .theme:
            return "还没有主题线索。之后常出现的主题会在这里沉淀。"
        case .person:
            return "还没有人物标签。"
        case .goal:
            return "还没有目标标签。"
        case .context:
            return "还没有场景标签。"
        }
    }

    private func loadTags() {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES AND type == %@", tagType.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "isCommon", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let results = (try? context.fetch(request)) ?? []
        tags = results.map { TagRow(id: $0.id, name: $0.name, isCommon: $0.isCommon) }
    }
}

private struct TagRow: Identifiable {
    let id: UUID
    let name: String
    let isCommon: Bool
}
