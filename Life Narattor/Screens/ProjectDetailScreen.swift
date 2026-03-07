import SwiftUI

struct ProjectDetailScreen: View {
    let project: ProjectItem
    @State private var selectedTab: ProjectDetailTab = .timeline

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            Picker("标签", selection: $selectedTab) {
                ForEach(ProjectDetailTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .timeline:
                        ProjectTimelineTab()
                    case .review:
                        ProjectReviewTab()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.name)
                .font(.title2.weight(.semibold))
            Text(project.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("更新于 \(formattedDate(project.updatedAt))")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("项目")
                .font(.caption)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

private struct ProjectTimelineTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("项目时间线")
                .font(.headline)
            ForEach(0..<4, id: \.self) { index in
                Text("• 项目记录占位 \(index + 1)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ProjectReviewTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("项目叙事")
                .font(.headline)
            Text("这个项目目前处于梳理阶段，还在逐步推进。")
                .font(.body)

            VStack(alignment: .leading, spacing: 12) {
                Text("AI回应")
                    .font(.headline)

                Picker("风格", selection: .constant(CommentStyle.gentle)) {
                    ForEach(CommentStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Text(CommentStyle.gentle.sampleText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("结构块")
                    .font(.headline)
                Text("时间轴 · 转折点 · 卡点 · 下一步")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("生成项目回顾") {}
                .buttonStyle(.bordered)
        }
    }
}
