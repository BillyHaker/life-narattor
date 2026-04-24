import CoreData
import SwiftUI

struct MonthlyReviewScreen: View {
    @Environment(\.managedObjectContext) private var context
    @State private var narrativeText: String = ""
    @State private var highlightDays: [TimelineDay] = []
    @State private var aiAnalysisText: String = ""
    @State private var isLoadingAnalysis = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("本月线索")
                        .font(.headline)
                    if isLoadingAnalysis {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("正在整理本月回顾…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(aiAnalysisText.isEmpty ? (narrativeText.isEmpty ? "这段时间还没有记录。" : narrativeText) : aiAnalysisText)
                            .font(.body)
                            .foregroundStyle((aiAnalysisText.isEmpty && narrativeText.isEmpty) ? .secondary : .primary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("结构概览")
                        .font(.headline)
                    Text(narrativeText.isEmpty ? "这段时间还没有记录。" : narrativeText)
                        .font(.body)
                        .foregroundStyle(narrativeText.isEmpty ? .secondary : .primary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("本月片段")
                        .font(.headline)

                    if highlightDays.isEmpty {
                        Text("这段时间还没有记录")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(highlightDays.prefix(6)) { day in
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("本月回顾")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: loadMonthlyData)
    }

    private func loadMonthlyData() {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        let range = RetrievalTimeRange(start: start, end: end, label: "最近30天")
        let service = ReviewRetrievalService(context: context)
        let brief = service.makeOpenReviewBrief(periodLabel: "过去一个月", range: range)
        let material = service.makeNarrativeMaterial(from: brief)
        if material.representativeUnits.isEmpty {
            narrativeText = ""
            highlightDays = []
            aiAnalysisText = ""
            return
        }

        narrativeText = service.makeNarrativeText(from: material, periodName: "本月")
        highlightDays = service.buildDays(from: material)
        requestAIAnalysis(material: material, periodName: "本月")
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · E"
        return formatter.string(from: date)
    }
}
