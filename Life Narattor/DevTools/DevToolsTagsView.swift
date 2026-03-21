import CoreData
import SwiftUI

struct DevToolsTagsView: View {
    let context: NSManagedObjectContext
    let aiService: AIService

    @State private var selectedVisibility: TagVisibilityFilter = .visible
    @State private var groupedTags: [(type: TagType, rows: [DevTagRow])] = []
    @State private var isRerunningSuggestions = false
    @State private var rerunStatusMessage: String?
    @State private var rerunDiagnostics: [TagRerunDiagnostic] = []

    var body: some View {
        VStack(spacing: 12) {
            maintenanceCard

            Picker("标签可见性", selection: $selectedVisibility) {
                ForEach(TagVisibilityFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            if groupedTags.allSatisfy({ $0.rows.isEmpty }) {
                ContentUnavailableView(
                    "没有标签",
                    systemImage: "tag.slash",
                    description: Text("当前筛选条件下没有可显示的标签。")
                )
            } else {
                List {
                    ForEach(groupedTags, id: \.type) { group in
                        if !group.rows.isEmpty {
                            Section(group.type.title) {
                                ForEach(group.rows) { row in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Text(row.name)
                                                .font(.body.weight(.semibold))
                                            if row.isCommon {
                                                pill("种子")
                                            }
                                            pill(row.isUserVisible ? "显性" : "隐性")
                                        }

                                        HStack(spacing: 12) {
                                            Text("链接 \(row.linkCount)")
                                            Text("创建于 \(row.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("全部标签")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: reload)
        .onChange(of: selectedVisibility) { _, _ in
            reload()
        }
    }

    private var maintenanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("标签维护")
                .font(.headline)

            Text("只对最近 10 条记录重新跑一次标签建议。会保留用户已确认的显性标签，只刷新建议标签。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await rerunTagSuggestionsForRecentCaptures()
                }
            } label: {
                HStack {
                    if isRerunningSuggestions {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(isRerunningSuggestions ? "处理中…" : "重跑最近 10 条记录标签建议")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRerunningSuggestions)

            if let rerunStatusMessage {
                Text(rerunStatusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if !rerunDiagnostics.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("最近一次结果")
                        .font(.subheadline.weight(.semibold))

                    ForEach(rerunDiagnostics) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.title)
                                    .font(.footnote.weight(.semibold))
                                    .lineLimit(1)
                                Spacer()
                                Text(item.statusTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(item.statusColor)
                            }

                            if let detail = item.detail, !detail.isEmpty {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }

    private func reload() {
        let tagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        switch selectedVisibility {
        case .all:
            tagRequest.predicate = nil
        case .visible:
            tagRequest.predicate = NSPredicate(format: "isUserVisible == YES")
        case .hidden:
            tagRequest.predicate = NSPredicate(format: "isUserVisible == NO")
        }
        tagRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        let links = (try? context.fetch(linkRequest)) ?? []
        let linkCounts = links.reduce(into: [UUID: Int]()) { partialResult, link in
            partialResult[link.tagID, default: 0] += 1
        }

        let tags = (try? context.fetch(tagRequest)) ?? []
        let rows = tags.map { entity in
            DevTagRow(
                id: entity.id,
                name: entity.name,
                type: TagType(rawValue: entity.type) ?? .theme,
                isUserVisible: entity.isUserVisible,
                isCommon: entity.isCommon,
                createdAt: entity.createdAt,
                linkCount: linkCounts[entity.id, default: 0]
            )
        }

        groupedTags = TagType.allCases.map { type in
            (type, rows.filter { $0.type == type })
        }
    }

    @MainActor
    private func rerunTagSuggestionsForRecentCaptures() async {
        guard !isRerunningSuggestions else { return }
        isRerunningSuggestions = true
        rerunStatusMessage = "正在读取最近 10 条记录…"
        rerunDiagnostics = []

        let captures = fetchRecentCaptures(limit: 10)
        let atomStore = AtomTagStore(context: context)
        let tagLibrary = loadTagLibrary()

        var processed = 0
        var skipped = 0
        var failed = 0
        var hiddenSuggestionTotal = 0
        var diagnostics: [TagRerunDiagnostic] = []

        for (index, capture) in captures.enumerated() {
            rerunStatusMessage = "正在处理第 \(index + 1)/\(captures.count) 条…"
            let title = devCaptureTitle(for: capture)

            guard let result = fetchTagSuggestionInput(captureID: capture.id) else {
                skipped += 1
                diagnostics.append(
                    TagRerunDiagnostic(
                        title: title,
                        status: .skipped,
                        detail: "跳过：没有可用的拆分/整理结构"
                    )
                )
                continue
            }

            let atomIDs = atomStore.fetchAtoms(captureID: capture.id).map(\.id)
            guard !atomIDs.isEmpty else {
                skipped += 1
                diagnostics.append(
                    TagRerunDiagnostic(
                        title: title,
                        status: .skipped,
                        detail: "跳过：没有 atoms"
                    )
                )
                continue
            }

            do {
                atomStore.clearSuggestedTags(for: atomIDs)
                let suggestions = try await aiService.suggestTags(atomization: result, tagLibrary: tagLibrary)
                atomStore.assignVisibleTagSuggestions(suggestions.suggestions, toFirstAtomOf: atomIDs)
                atomStore.assignHiddenTagSuggestions(suggestions.hiddenSuggestions, toAllAtoms: atomIDs)
                processed += 1
                hiddenSuggestionTotal += suggestions.hiddenSuggestions.count
                diagnostics.append(
                    TagRerunDiagnostic(
                        title: title,
                        status: suggestions.hiddenSuggestions.isEmpty ? .updatedWithoutHidden : .updated,
                        detail: "显性建议 \(suggestions.suggestions.count) 个，隐性建议 \(suggestions.hiddenSuggestions.count) 个"
                    )
                )
            } catch {
                failed += 1
                diagnostics.append(
                    TagRerunDiagnostic(
                        title: title,
                        status: .failed,
                        detail: "失败：\(describe(error: error))"
                    )
                )
            }
        }

        reload()
        isRerunningSuggestions = false
        rerunDiagnostics = diagnostics
        rerunStatusMessage = "完成：更新 \(processed) 条，跳过 \(skipped) 条，失败 \(failed) 条。累计拿到隐性建议 \(hiddenSuggestionTotal) 个。"
    }

    @MainActor
    private func fetchRecentCaptures(limit: Int) -> [CaptureEntity] {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "mode == %@", CaptureInputMode.log.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = limit
        return (try? context.fetch(request)) ?? []
    }

    @MainActor
    private func fetchAtomizationPayload(captureID: UUID) -> AtomizationArtifactPayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@ AND sourceCaptureID == %@", "atomization_payload", captureID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AtomizationArtifactPayload.decode(from: artifact.contentJSON)
    }

    @MainActor
    private func fetchTagSuggestionInput(captureID: UUID) -> AtomizeResult? {
        if let payload = fetchAtomizationPayload(captureID: captureID) {
            return AtomizeResult(
                semanticChunks: payload.semanticChunks,
                recordUnits: payload.recordUnits,
                atomizeVersion: payload.atomizeVersion
            )
        }

        if let archive = fetchAssistArchivePayload(captureID: captureID) {
            let recordUnits = archive.card.effectiveRecordUnits.map {
                RecordUnitDraft(
                    summary: $0.summary,
                    contextAttributes: [],
                    behavioralChain: $0.nextSteps,
                    resultOrState: [],
                    tagHints: [],
                    confidence: nil,
                    startChar: nil,
                    endChar: nil
                )
            }

            guard !recordUnits.isEmpty else { return nil }
            return AtomizeResult(
                semanticChunks: [],
                recordUnits: recordUnits,
                atomizeVersion: "assist_archive_tags_v1"
            )
        }

        return nil
    }

    @MainActor
    private func fetchAssistArchivePayload(captureID: UUID) -> AssistArchivePayload? {
        let request = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
        request.predicate = NSPredicate(format: "artifactType == %@ AND sourceCaptureID == %@", "assist_archive_card", captureID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        guard let artifact = try? context.fetch(request).first else { return nil }
        return AssistArchivePayload.decode(from: artifact.contentJSON)
    }

    @MainActor
    private func loadTagLibrary() -> TagLibrary {
        TagLibrary(
            project: fetchVisibleTagNames(type: .project),
            habit: fetchVisibleTagNames(type: .habit),
            theme: fetchVisibleTagNames(type: .theme),
            person: fetchVisibleTagNames(type: .person),
            goal: fetchVisibleTagNames(type: .goal),
            context: fetchVisibleTagNames(type: .context)
        )
    }

    @MainActor
    private func fetchVisibleTagNames(type: TagType) -> [String] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "type == %@ AND isUserVisible == YES", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request).map(\.name)) ?? []
    }

    @MainActor
    private func devCaptureTitle(for capture: CaptureEntity) -> String {
        let base = (capture.cleanText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? capture.cleanText! : capture.rawText)
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return capture.createdAt.formatted(date: .abbreviated, time: .shortened)
        }
        return String(trimmed.prefix(24))
    }

    private func describe(error: Error) -> String {
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .missingAPIKey:
                return "AI 未配置"
            case .invalidResponse:
                return "AI 返回格式异常"
            case .httpStatus(let code):
                return "AI 服务异常 HTTP\(code)"
            case .emptyResponse:
                return "AI 返回为空"
            case .unsupported:
                return "当前路径不支持"
            }
        }
        return error.localizedDescription
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

private enum TagVisibilityFilter: String, CaseIterable, Identifiable {
    case visible
    case hidden
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .visible:
            return "显性"
        case .hidden:
            return "隐性"
        case .all:
            return "全部"
        }
    }
}

private struct DevTagRow: Identifiable {
    let id: UUID
    let name: String
    let type: TagType
    let isUserVisible: Bool
    let isCommon: Bool
    let createdAt: Date
    let linkCount: Int
}

private struct TagRerunDiagnostic: Identifiable {
    enum Status {
        case updated
        case updatedWithoutHidden
        case skipped
        case failed
    }

    let id = UUID()
    let title: String
    let status: Status
    let detail: String?

    var statusTitle: String {
        switch status {
        case .updated:
            return "已更新"
        case .updatedWithoutHidden:
            return "无隐性"
        case .skipped:
            return "跳过"
        case .failed:
            return "失败"
        }
    }

    var statusColor: Color {
        switch status {
        case .updated:
            return .green
        case .updatedWithoutHidden:
            return .orange
        case .skipped:
            return .secondary
        case .failed:
            return .red
        }
    }
}
