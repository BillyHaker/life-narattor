import CoreData
import SwiftUI

struct ProjectsListScreen: View {
    @Environment(\.managedObjectContext) private var context
    @State private var projects: [ProjectItem] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if projects.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(projects) { project in
                                NavigationLink(value: project) {
                                    ProjectRowCard(project: project)
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
            .navigationTitle("线索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        TagManagerScreen()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: ProjectItem.self) { project in
                ProjectDetailScreen(project: project)
            }
            .onAppear(perform: loadProjects)
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("还没有长期线索。等你多记几次，常出现的项目、主题和方向会在这里沉淀下来。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private func loadProjects() {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "isUserVisible == YES AND type == %@", TagType.project.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let results = (try? context.fetch(request)) ?? []
        projects = results.map { tag in
            let count = fetchAtomCount(tagID: tag.id)
            let summary = count == 0 ? "还没有新的片段" : "\(count) 条相关片段"
            return ProjectItem(
                id: tag.id,
                name: tag.name,
                summary: summary,
                updatedAt: tag.createdAt
            )
        }
    }

    private func fetchAtomCount(tagID: UUID) -> Int {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "tagID == %@", tagID as CVarArg)
        return (try? context.count(for: request)) ?? 0
    }
}

private struct ProjectRowCard: View {
    let project: ProjectItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.headline)
            Text(project.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("更新于 \(formattedDate(project.updatedAt))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}
