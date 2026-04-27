import CoreData
import SwiftUI

struct MonthlyReviewScreen: View {
    @Environment(\.managedObjectContext) private var context
    @State private var reviewData: RangeReviewData? = nil
    @State private var aiAnalysisText: String = ""
    @State private var isLoadingAnalysis = false
    @State private var expandedEvidenceGroupIDs: Set<UUID> = []
    @State private var isSourceDaysExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let reviewData {
                    overviewCard(reviewData)

                    if !reviewData.sections.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(reviewData.sections) { section in
                                sectionCard(section)
                            }
                        }
                    }

                    if !reviewData.evidenceGroups.isEmpty {
                        evidenceCard(reviewData)
                    }

                    if !reviewData.followupPrompts.isEmpty {
                        followupCard(reviewData)
                    }

                    sourceDaysCard(reviewData)
                } else {
                    emptyStateCard
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("30 天回顾")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: loadMonthlyData)
    }

    private func loadMonthlyData() {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let range = RetrievalTimeRange(start: start, end: now, label: "过去 30 天")
        let service = ReviewRetrievalService(context: context)

        guard let data = service.makeRangeReviewData(periodName: "过去 30 天", periodLabel: "最近 30 天", range: range) else {
            reviewData = nil
            aiAnalysisText = ""
            isLoadingAnalysis = false
            return
        }

        reviewData = data
        requestAIAnalysis(material: data.material, periodName: data.periodName)
    }

    private func requestAIAnalysis(material: NarrativeMaterial, periodName: String) {
        isLoadingAnalysis = true
        aiAnalysisText = ""
        Task {
            do {
                let text = try await AIServiceFactory.make().analyzeNarrativeMaterial(material, periodName: periodName, followupQuestion: nil)
                await MainActor.run {
                    aiAnalysisText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    isLoadingAnalysis = false
                }
            } catch {
                await MainActor.run {
                    aiAnalysisText = ""
                    isLoadingAnalysis = false
                }
            }
        }
    }

    private func overviewCard(_ reviewData: RangeReviewData) -> some View {
        reviewCard(title: "30 天总览", accent: reviewData.periodLabel) {
            VStack(alignment: .leading, spacing: 12) {
                Text("先看最近 30 天整体的主线，再决定要不要追进去某一天。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if isLoadingAnalysis {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("正在整理最近 30 天的整体变化…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(aiAnalysisText.isEmpty ? reviewData.summaryText : aiAnalysisText)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    infoPill("\(reviewData.activeDayCount) 天有记录")
                    infoPill("\(reviewData.totalRecordCount) 条重点材料")
                }

                if !reviewData.overviewSignals.isEmpty {
                    signalRow(reviewData.overviewSignals)
                }
            }
        }
    }

    private func sectionCard(_ section: RangeReviewSection) -> some View {
        reviewCard(title: section.title, accent: section.accent) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(section.bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.accentColor.opacity(0.28))
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)
                        Text(bullet)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func evidenceCard(_ reviewData: RangeReviewData) -> some View {
        reviewCard(title: "证据", accent: "支撑") {
            VStack(alignment: .leading, spacing: 12) {
                Text("这些材料帮助确认最近 30 天的判断，不需要把每天都重新看一遍。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(reviewData.evidenceGroups) { group in
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
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.rationale)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(group.highlights, id: \.self) { highlight in
                                Text("• \(highlight)")
                                    .font(.footnote)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if !group.sourceDays.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(group.sourceDays.prefix(3)) { day in
                                        NavigationLink {
                                            DayDetailScreen(day: day)
                                        } label: {
                                            sourceDayChip(for: day)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(group.highlights.prefix(2).joined(separator: "；"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }

    private func followupCard(_ reviewData: RangeReviewData) -> some View {
        reviewCard(title: "可以继续追问", accent: "下一步") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(reviewData.followupPrompts, id: \.self) { prompt in
                    Text(prompt)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }

    private func sourceDaysCard(_ reviewData: RangeReviewData) -> some View {
        reviewCard(title: "来源日期", accent: "追溯") {
            DisclosureGroup("看看这些判断主要来自哪几天", isExpanded: $isSourceDaysExpanded) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(reviewData.sourceDays) { day in
                        NavigationLink {
                            DayDetailScreen(day: day)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(formattedDate(day.date))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(day.primaryLine)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 10)
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var emptyStateCard: some View {
        reviewCard(title: "最近 30 天还很轻", accent: "空") {
            Text("最近 30 天还没有足够的记录形成整段回顾。先把片段留在这里，过一段时间再回来会更有意思。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func reviewCard<Content: View>(title: String, accent: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(accent)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func infoPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
    }

    private func signalRow(_ signals: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(signals, id: \.self) { signal in
                    Text(signal)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }

    private func sourceDayChip(for day: TimelineDay) -> some View {
        Text(formattedDate(day.date))
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Capsule())
    }
}
