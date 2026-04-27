import CoreData
import SwiftUI

struct DevToolsReviewMaterialView: View {
    let context: NSManagedObjectContext

    @State private var availableDays: [Date] = []
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    @State private var rows: [ReviewMaterialDebugRow] = []
    @State private var repairStatusMessage: String?
    @State private var isRepairing = false
    @State private var isBackfilling = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("检查范围")
                        .font(.headline)

                    if availableDays.isEmpty {
                        Text("最近 30 天没有记录。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("日期", selection: $selectedDay) {
                            ForEach(availableDays, id: \.self) { day in
                                Text(formattedDay(day)).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Text("这里只看“为什么这一天没有回顾材料”。正式记录是 `mode == log`；真正能给 AI 回顾用的是 `atomization_payload.recordUnits`。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        backfillLegacyAssistPayloads()
                    } label: {
                        HStack {
                            if isBackfilling {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isBackfilling ? "回填中…" : "回填这一天的旧 assist 回顾材料")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBackfilling || missingLegacyPayloadCount == 0)

                    Button {
                        repairStuckFormalRecords()
                    } label: {
                        HStack {
                            if isRepairing {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isRepairing ? "处理中…" : "将卡住的正式记录重置为等待拆分")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRepairing || stuckFormalRecordCount == 0)

                    if let repairStatusMessage, !repairStatusMessage.isEmpty {
                        Text(repairStatusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                if rows.isEmpty {
                    ContentUnavailableView(
                        "没有记录",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("这一天还没有 capture。")
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(rows) { row in
                            rowCard(row)
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("回顾材料诊断")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: reload)
        .onChange(of: selectedDay) { _, _ in
            reloadRows()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(formattedDay(selectedDay))
                .font(.headline)

            Text(summaryText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var summaryText: String {
        guard !rows.isEmpty else {
            return "这一天还没有 capture。"
        }

        return "共 \(rows.count) 条 capture；正式记录 \(formalRecordCount) 条；可进入回顾 \(reviewEligibleCount) 条；有 atomization payload 的 \(payloadBackedCount) 条；真正有 recordUnits 的 \(recordUnitBackedCount) 条；卡在 cleanReady 的正式记录 \(stuckFormalRecordCount) 条。"
    }

    private var formalRecordCount: Int {
        rows.filter(\.isFormalRecord).count
    }

    private var reviewEligibleCount: Int {
        rows.filter(\.eligibleForReview).count
    }

    private var payloadBackedCount: Int {
        rows.filter(\.hasAtomizationPayload).count
    }

    private var recordUnitBackedCount: Int {
        rows.filter { $0.recordUnitsCount > 0 }.count
    }

    private var stuckFormalRecordCount: Int {
        rows.filter(\.shouldAutoRepair).count
    }

    private var missingLegacyPayloadCount: Int {
        rows.filter { $0.hasAssistArchive && !$0.hasAtomizationPayload }.count
    }

    private func reload() {
        loadAvailableDays()
        reloadRows()
    }

    private func loadAvailableDays() {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: end) ?? end
        request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", start as CVarArg, end as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let captures = (try? context.fetch(request)) ?? []
        availableDays = Array(NSOrderedSet(array: captures.map { calendar.startOfDay(for: $0.createdAt) })) as? [Date] ?? []
        if let first = availableDays.first, !availableDays.contains(selectedDay) {
            selectedDay = first
        }
    }

    private func reloadRows() {
        let interval = dayInterval(for: selectedDay)
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            interval.start as CVarArg,
            interval.end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let captures = (try? context.fetch(request)) ?? []
        rows = captures.map(makeRow)
    }

    private func makeRow(for entity: CaptureEntity) -> ReviewMaterialDebugRow {
        let payload = fetchAtomizationPayload(captureID: entity.id)
        let recordUnitsCount = payload?.recordUnits.count ?? 0
        let snippetSource = entity.normalizedCleanTextForReview ?? entity.rawText
        let snippet = String(snippetSource.prefix(60))

        return ReviewMaterialDebugRow(
            id: entity.id,
            snippet: snippet,
            createdAt: entity.createdAt,
            modeTitle: entity.resolvedInputMode.title,
            inputTypeTitle: inputTypeTitle(for: entity),
            processingStateTitle: entity.resolvedReviewProcessingState.displayText,
            atomsCount: Int(entity.atomsCount),
            hasAssistArchive: fetchAssistArchive(captureID: entity.id) != nil,
            hasAtomizationPayload: payload != nil,
            recordUnitsCount: recordUnitsCount,
            isFormalRecord: entity.isFormalRecord,
            eligibleForReview: entity.isEligibleForReviewTimeline,
            isHiddenFromFeed: entity.isHiddenFromFeed,
            shouldAutoRepair: entity.shouldAutoAtomizeForFormalRecord && entity.resolvedReviewProcessingState == .cleanReady,
            atomizationError: entity.atomizationError
        )
    }

    private func fetchAtomizationPayload(captureID: UUID) -> AtomizationArtifactPayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@ AND sourceCaptureID == %@", "atomization_payload", captureID as CVarArg)
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AtomizationArtifactPayload.decode(from: artifact.contentJSON)
    }

    private func fetchAssistArchive(captureID: UUID) -> AssistArchivePayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@ AND sourceCaptureID == %@", "assist_archive_card", captureID as CVarArg)
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AssistArchivePayload.decode(from: artifact.contentJSON)
    }

    @ViewBuilder
    private func rowCard(_ row: ReviewMaterialDebugRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.snippet.isEmpty ? "空内容" : row.snippet)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text("\(formattedTime(row.createdAt)) · \(row.modeTitle) · \(row.inputTypeTitle)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if row.shouldAutoRepair {
                    statusPill("卡住", color: .orange)
                } else if row.recordUnitsCount > 0 {
                    statusPill("可回顾", color: .green)
                } else if row.hasAtomizationPayload {
                    statusPill("无单元", color: .blue)
                } else {
                    statusPill("缺材料", color: .gray)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                debugLine("状态", row.processingStateTitle)
                debugLine("atoms", "\(row.atomsCount)")
                debugLine("assist", row.hasAssistArchive ? "有" : "无")
                debugLine("payload", row.hasAtomizationPayload ? "有" : "无")
                debugLine("recordUnits", "\(row.recordUnitsCount)")
                debugLine("正式记录", row.isFormalRecord ? "是" : "否")
                debugLine("参与回顾", row.eligibleForReview ? "是" : "否")
                debugLine("记录页隐藏", row.isHiddenFromFeed ? "是" : "否")
                if let atomizationError = row.atomizationError, !atomizationError.isEmpty {
                    debugLine("错误", atomizationError)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func debugLine(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 58, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statusPill(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func inputTypeTitle(for entity: CaptureEntity) -> String {
        switch CaptureInputType(rawValue: entity.inputType ?? "") ?? .text {
        case .text:
            return "文字"
        case .voice:
            return "语音"
        }
    }

    private func repairStuckFormalRecords() {
        guard !isRepairing else { return }
        isRepairing = true

        let interval = dayInterval(for: selectedDay)
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt < %@",
            interval.start as CVarArg,
            interval.end as CVarArg
        )

        let captures = (try? context.fetch(request)) ?? []
        let repairable = captures.filter { entity in
            entity.shouldAutoAtomizeForFormalRecord && entity.resolvedReviewProcessingState == .cleanReady
        }

        guard !repairable.isEmpty else {
            repairStatusMessage = "这一天没有卡在 cleanReady 的正式记录。"
            isRepairing = false
            return
        }

        for entity in repairable {
            entity.processingState = CaptureProcessingState.pendingSplit.rawValue
            entity.atomizationError = nil
        }

        do {
            try context.save()
            NotificationCenter.default.post(name: .capturePendingAtomizationRequested, object: nil)
            repairStatusMessage = "已重置 \(repairable.count) 条正式记录为等待拆分。"
            reloadRows()
        } catch {
            repairStatusMessage = "重置失败：\(error.localizedDescription)"
        }

        isRepairing = false
    }

    private func backfillLegacyAssistPayloads() {
        guard !isBackfilling else { return }
        isBackfilling = true

        let summary = ReviewMaterialRepairService(context: context).backfillLegacyAssistArchivePayloads(in: dayInterval(for: selectedDay))
        repairStatusMessage = "检查 \(summary.inspected) 条，回填 \(summary.backfilled) 条，跳过 \(summary.skipped) 条。"
        reloadRows()
        isBackfilling = false
    }

    private func dayInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return DateInterval(start: start, end: end)
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy/MM/dd · EEEE"
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private struct ReviewMaterialDebugRow: Identifiable {
    let id: UUID
    let snippet: String
    let createdAt: Date
    let modeTitle: String
    let inputTypeTitle: String
    let processingStateTitle: String
    let atomsCount: Int
    let hasAssistArchive: Bool
    let hasAtomizationPayload: Bool
    let recordUnitsCount: Int
    let isFormalRecord: Bool
    let eligibleForReview: Bool
    let isHiddenFromFeed: Bool
    let shouldAutoRepair: Bool
    let atomizationError: String?
}
