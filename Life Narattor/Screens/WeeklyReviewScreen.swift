import CoreData
import SwiftUI

struct WeeklyReviewScreen: View {
    @Environment(\.managedObjectContext) private var context
    @State private var narrativeText: String = ""
    @State private var highlightDays: [TimelineDay] = []
    @State private var selectedCommentStyle: CommentStyle = .gentle
    @State private var isCommentEnabled: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("自我叙事")
                        .font(.headline)
                    Text(narrativeText.isEmpty ? "这段时间还没有记录。" : narrativeText)
                        .font(.body)
                        .foregroundStyle(narrativeText.isEmpty ? .secondary : .primary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("AI 的回应")
                            .font(.headline)
                        Spacer()
                        Toggle("关闭回应", isOn: $isCommentEnabled)
                            .labelsHidden()
                    }

                    if isCommentEnabled {
                        Picker("风格", selection: $selectedCommentStyle) {
                            ForEach(CommentStyle.allCases) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text(selectedCommentStyle.sampleText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("本周片段")
                        .font(.headline)

                    if highlightDays.isEmpty {
                        Text("这段时间还没有记录")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(highlightDays.prefix(5)) { day in
                            NavigationLink {
                                DayDetailScreen(day: day)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(formattedDate(day.date))
                                        .font(.subheadline.weight(.semibold))
                                    if let first = day.highlights.first {
                                        Text(first)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("本周回顾")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: loadWeeklyData)
    }

    private func loadWeeklyData() {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else {
            narrativeText = ""
            highlightDays = []
            return
        }

        let captures = fetchCaptures(from: interval.start, to: interval.end)
        if captures.isEmpty {
            narrativeText = ""
            highlightDays = []
            return
        }

        narrativeText = makeSelfNarrative(from: captures, periodName: "本周")
        highlightDays = buildDays(from: captures)
    }

    private func fetchCaptures(from start: Date, to end: Date) -> [CaptureEntity] {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            start as CVarArg,
            end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func buildDays(from captures: [CaptureEntity]) -> [TimelineDay] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: captures) { capture in
            calendar.startOfDay(for: capture.createdAt)
        }

        return grouped.map { date, items in
            let sorted = items.sorted { $0.createdAt > $1.createdAt }
            let highlights = sorted
                .compactMap { $0.cleanText ?? $0.rawText }
                .prefix(6)
            let highlightIDs = sorted
                .map { $0.id }
                .prefix(6)
            return TimelineDay(
                id: UUID(),
                date: date,
                highlights: Array(highlights),
                highlightCaptureIDs: Array(highlightIDs),
                hasNarrative: items.count >= 3
            )
        }
        .sorted { $0.date > $1.date }
    }

    private func makeSelfNarrative(from captures: [CaptureEntity], periodName: String) -> String {
        let top = captures
            .sorted { $0.createdAt > $1.createdAt }
            .compactMap { $0.cleanText ?? $0.rawText }
            .prefix(3)
        let summary = top.joined(separator: "、")
        return "\(periodName)我记录了\(captures.count)条，主要是：\(summary)。"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }
}
