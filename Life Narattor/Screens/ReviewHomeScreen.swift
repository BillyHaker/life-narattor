import SwiftUI

struct ReviewHomeScreen: View {
    private let snippets: [ReviewSnippet] = [
        ReviewSnippet(id: UUID(), title: "你最近常提到", detail: "项目、节奏、整理"),
        ReviewSnippet(id: UUID(), title: "最近的节奏", detail: "更稳定"),
        ReviewSnippet(id: UUID(), title: "关键节点", detail: "整理了方向 / 跟进计划")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        NavigationLink("本周回顾") {
                            WeeklyReviewScreen()
                        }
                        .buttonStyle(.bordered)

                        NavigationLink("本月回顾") {
                            MonthlyReviewScreen()
                        }
                        .buttonStyle(.bordered)

                        Button("按项目回顾") {}
                            .buttonStyle(.bordered)

                        Button("按主题回顾") {}
                            .buttonStyle(.bordered)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("记忆片段")
                            .font(.headline)

                        ForEach(snippets) { snippet in
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
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("还没有可回顾内容。先记录几条，晚上回来看看。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("回顾")
            .background(Color(.systemGroupedBackground))
        }
    }
}
