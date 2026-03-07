import SwiftUI

struct ProjectsListScreen: View {
    private let projects: [ProjectItem] = [
        ProjectItem(
            id: UUID(),
            name: "Life Narrator",
            summary: "产品内测与方向推进",
            updatedAt: Date()
        ),
        ProjectItem(
            id: UUID(),
            name: "学习系统",
            summary: "整理学习节奏",
            updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        )
    ]

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
            .navigationTitle("项目")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: ProjectItem.self) { project in
                ProjectDetailScreen(project: project)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("还没有项目。创建一个项目标签，之后好整理回顾。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
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
