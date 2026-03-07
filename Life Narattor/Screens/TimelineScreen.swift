import SwiftUI

struct TimelineScreen: View {
    @State private var selectedScope: TimelineScope = .today

    private let days: [TimelineDay] = [
        TimelineDay(
            id: UUID(),
            date: Date(),
            highlights: ["开会做了进度对齐", "午饭后散步十分钟", "晚上读了半小时书"],
            hasNarrative: true
        ),
        TimelineDay(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            highlights: ["整理了项目方向", "和同事对齐目标"],
            hasNarrative: false
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("范围", selection: $selectedScope) {
                    ForEach(TimelineScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if days.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(days) { day in
                                NavigationLink(value: day) {
                                    TimelineDayCard(day: day)
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
            .navigationDestination(for: TimelineDay.self) { day in
                DayDetailScreen(day: day)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("这段时间还没有记录")
                .font(.body)
                .foregroundStyle(.secondary)
            Button("去记录") {}
                .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }
}

private struct TimelineDayCard: View {
    let day: TimelineDay

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formattedDate(day.date))
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(day.highlights.prefix(6), id: \.self) { highlight in
                    Text("• \(highlight)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(day.hasNarrative ? "查看日记" : "生成日记")
                .font(.footnote.weight(.semibold))
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
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }
}
