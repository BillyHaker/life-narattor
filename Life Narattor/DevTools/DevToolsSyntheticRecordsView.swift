import CoreData
import SwiftUI

struct DevToolsSyntheticRecordsView: View {
    let context: NSManagedObjectContext

    @State private var selectedPersona: SyntheticPersona = .officeWorker
    @State private var selectedVolume: SyntheticVolume = .medium
    @State private var selectedHorizon: SyntheticTimeHorizon = .month
    @State private var shouldRunSplitAndTags = true
    @State private var isRunning = false
    @State private var statusLines: [String] = []
    @State private var generatedCount = 0
    @State private var splitCount = 0
    @State private var failedCount = 0

    var body: some View {
        List {
            Section("生成方案") {
                Picker("角色", selection: $selectedPersona) {
                    ForEach(SyntheticPersona.allCases) { persona in
                        Text(persona.title).tag(persona)
                    }
                }

                Picker("数量", selection: $selectedVolume) {
                    ForEach(SyntheticVolume.allCases) { volume in
                        Text(volume.title).tag(volume)
                    }
                }

                Picker("时间跨度", selection: $selectedHorizon) {
                    ForEach(SyntheticTimeHorizon.allCases) { horizon in
                        Text(horizon.title).tag(horizon)
                    }
                }

                Toggle("生成后立即拆分并推荐标签", isOn: $shouldRunSplitAndTags)
            }

            Section("执行") {
                Button(isRunning ? "生成中…" : "生成测试记录") {
                    runGeneration()
                }
                .disabled(isRunning)

                Button("清除测试记录") {
                    clearSyntheticRecords()
                }
                .disabled(isRunning)
                .foregroundStyle(.red)
            }

            Section("结果") {
                DevToolsInfoRow(title: "已创建", value: "\(generatedCount)")
                DevToolsInfoRow(title: "已拆分", value: "\(splitCount)")
                DevToolsInfoRow(title: "失败", value: "\(failedCount)")
            }

            if !statusLines.isEmpty {
                Section("日志") {
                    ForEach(Array(statusLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Synthetic Records")
    }

    private func runGeneration() {
        isRunning = true
        generatedCount = 0
        splitCount = 0
        failedCount = 0
        statusLines = []

        Task {
            let generator = SyntheticRecordGenerator(context: context, aiService: AIServiceFactory.make())
            do {
                let report = try await generator.generate(
                    persona: selectedPersona,
                    count: selectedVolume.count,
                    horizonDays: selectedHorizon.days,
                    runSplitAndTags: shouldRunSplitAndTags,
                    onProgress: { line, created, split, failed in
                        await MainActor.run {
                            statusLines.append(line)
                            generatedCount = created
                            splitCount = split
                            failedCount = failed
                        }
                    }
                )
                await MainActor.run {
                    statusLines.append("完成：共 \(report.createdCount) 条，拆分 \(report.splitCount) 条，失败 \(report.failedCount) 条。")
                    isRunning = false
                }
            } catch {
                await MainActor.run {
                    statusLines.append("生成失败：\(error.localizedDescription)")
                    isRunning = false
                }
            }
        }
    }

    private func clearSyntheticRecords() {
        isRunning = true
        Task {
            let generator = SyntheticRecordGenerator(context: context, aiService: AIServiceFactory.make())
            let removed = await generator.clearSyntheticCaptures()
            await MainActor.run {
                statusLines.append("已清除 \(removed) 条测试记录。")
                generatedCount = 0
                splitCount = 0
                failedCount = 0
                isRunning = false
            }
        }
    }
}

enum SyntheticPersona: String, CaseIterable, Identifiable {
    case officeWorker
    case universityStudent
    case mixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .officeWorker:
            return "上班族"
        case .universityStudent:
            return "大学生"
        case .mixed:
            return "混合样本"
        }
    }
}

enum SyntheticVolume: Int, CaseIterable, Identifiable {
    case small = 12
    case medium = 30
    case large = 60

    var id: Int { rawValue }
    var count: Int { rawValue }

    var title: String {
        "\(rawValue) 条"
    }
}

enum SyntheticTimeHorizon: Int, CaseIterable, Identifiable {
    case week = 7
    case month = 30
    case quarter = 90

    var id: Int { rawValue }
    var days: Int { rawValue }

    var title: String {
        switch self {
        case .week:
            return "近 7 天"
        case .month:
            return "近 30 天"
        case .quarter:
            return "近 90 天"
        }
    }
}

struct SyntheticGenerationReport {
    let createdCount: Int
    let splitCount: Int
    let failedCount: Int
}

struct SyntheticRecordGenerator {
    let context: NSManagedObjectContext
    let aiService: AIService

    private let syntheticMarkerPrefix = "synthetic_fixture:"

    func generate(
        persona: SyntheticPersona,
        count: Int,
        horizonDays: Int,
        runSplitAndTags: Bool,
        onProgress: @escaping @Sendable (String, Int, Int, Int) async -> Void
    ) async throws -> SyntheticGenerationReport {
        let templates = makeTemplates(for: persona)
        let calendar = Calendar.current
        let now = Date()
        var created = 0
        var split = 0
        var failed = 0

        for index in 0..<count {
            let template = templates[index % templates.count]
            let offset = min(horizonDays - 1, index * max(horizonDays / max(count, 1), 1))
            let createdAt = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
            let clean = CleanDefiller.clean(template.text)
            let captureID = try await createCapture(
                rawText: template.text,
                cleanText: clean.cleanText,
                createdAt: createdAt,
                marker: "\(syntheticMarkerPrefix)\(persona.rawValue)"
            )
            created += 1
            await onProgress("已创建 \(created)/\(count)：\(template.shortTitle)", created, split, failed)

            if runSplitAndTags {
                do {
                    let coordinator = AtomizationCoordinator(context: context, aiService: aiService)
                    try await coordinator.atomizeCaptureIfNeeded(
                        captureID: captureID,
                        cleanText: clean.cleanText,
                        progress: { message in
                            Task {
                                await onProgress("第 \(created) 条：\(message)", created, split, failed)
                            }
                        }
                    )
                    split += 1
                } catch {
                    failed += 1
                    try? await markSplitFailed(captureID: captureID, reason: error.localizedDescription)
                    await onProgress("第 \(created) 条拆分失败：\(template.shortTitle)", created, split, failed)
                }
            }
        }

        return SyntheticGenerationReport(createdCount: created, splitCount: split, failedCount: failed)
    }

    func clearSyntheticCaptures() async -> Int {
        await context.perform {
            let captureRequest = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
            captureRequest.predicate = NSPredicate(format: "ackDetail BEGINSWITH %@", syntheticMarkerPrefix)
            let captures = (try? context.fetch(captureRequest)) ?? []
            let captureIDs = captures.map(\.id)

            for captureID in captureIDs {
                let atomStore = AtomTagStore(context: context)
                atomStore.clearAtomsForCapture(captureID: captureID)
            }

            let artifactRequest = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")
            artifactRequest.predicate = NSPredicate(format: "sourceCaptureID IN %@", captureIDs)
            let artifacts = (try? context.fetch(artifactRequest)) ?? []
            artifacts.forEach { context.delete($0) }
            captures.forEach { context.delete($0) }

            let orphanTagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
            orphanTagRequest.predicate = NSPredicate(format: "isUserVisible == NO")
            let hiddenTags = (try? context.fetch(orphanTagRequest)) ?? []
            let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
            let links = (try? context.fetch(linkRequest)) ?? []
            let linkedTagIDs = Set(links.map(\.tagID))
            hiddenTags.filter { !linkedTagIDs.contains($0.id) }.forEach { context.delete($0) }

            try? context.save()
            return captures.count
        }
    }

    private func createCapture(rawText: String, cleanText: String, createdAt: Date, marker: String) async throws -> UUID {
        try await context.perform {
            let entity = CaptureEntity(context: context)
            entity.id = UUID()
            entity.createdAt = createdAt
            entity.rawText = rawText
            entity.cleanText = cleanText
            entity.ackTitle = "测试记录"
            entity.ackDetail = marker
            entity.dayPart = dayPart(for: createdAt).rawValue
            entity.mode = CaptureInputMode.log.rawValue
            entity.atomsCount = 0
            entity.processingState = CaptureProcessingState.cleanReady.rawValue
            entity.inputType = CaptureInputType.text.rawValue
            entity.transcriptionStatus = nil
            entity.transcriptionError = nil
            entity.atomizationError = nil
            entity.atomizeVersion = nil
            try context.save()
            return entity.id
        }
    }

    private func markSplitFailed(captureID: UUID, reason: String) async throws {
        try await context.perform {
            let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
            request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)
            guard let entity = try context.fetch(request).first else { return }
            entity.processingState = CaptureProcessingState.splitFailed.rawValue
            entity.atomizationError = reason
            try context.save()
        }
    }

    private func dayPart(for date: Date) -> DayPart {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case ..<12: return .morning
        case 12..<18: return .afternoon
        default: return .evening
        }
    }

    private func makeTemplates(for persona: SyntheticPersona) -> [SyntheticTemplate] {
        switch persona {
        case .officeWorker:
            return officeWorkerTemplates
        case .universityStudent:
            return studentTemplates
        case .mixed:
            return Array((officeWorkerTemplates + studentTemplates).shuffled())
        }
    }

    private var officeWorkerTemplates: [SyntheticTemplate] {
        [
            .init(shortTitle: "晨会与老板", text: "今天早上开晨会的时候，新老板又提了一次节奏问题，我一下子有点紧，后面开完会才慢慢缓过来。"),
            .init(shortTitle: "加班补任务", text: "上午该做完的那部分需求还是没收掉，晚上只能再补一段时间，不然周一会很被动。"),
            .init(shortTitle: "午饭没胃口", text: "这两天工作压力一上来，我中午就不太想吃饭，今天又是只吃了几口。"),
            .init(shortTitle: "通勤疲惫", text: "今天通勤特别拖，路上一直在想工作，到了公司之前就已经觉得很累。"),
            .init(shortTitle: "深度工作顺", text: "我今天下午有一段两小时的深度工作，状态很好，那个时候推进明显快很多。"),
            .init(shortTitle: "晚间复盘", text: "晚上复盘的时候发现，其实我这周最卡的还是需求切换太频繁，不是能力问题。"),
            .init(shortTitle: "新老板适应", text: "跟新老板沟通的时候，我会下意识想把事情说得更完整，结果反而越说越乱。"),
            .init(shortTitle: "晨间启动", text: "今天起床之后很快坐到桌前，把最难的那件事先开了头，整个人轻松很多。"),
            .init(shortTitle: "同事支持", text: "下午和同事对齐的时候，对方帮我补上了一个漏掉的点，我当时有种被接住的感觉。"),
            .init(shortTitle: "项目推进", text: "Life Narrator 这个项目今天主要推进了标签库那部分，想到后面可以回顾得更清楚，我挺兴奋。"),
            .init(shortTitle: "拖延波动", text: "我发现自己一碰到要发给老板确认的内容就会拖，自己会一直想再改一版。"),
            .init(shortTitle: "周末恢复", text: "这周末如果不早点睡，我下周一大概率又会很难进入状态。")
        ]
    }

    private var studentTemplates: [SyntheticTemplate] {
        [
            .init(shortTitle: "早课赶路", text: "今天为了赶八点的早课起得比较早，虽然很困，但到教室的时候居然没有那么烦躁。"),
            .init(shortTitle: "实验报告", text: "实验报告还是拖到了晚上才写，我一想到数据还没整理完就有点想逃。"),
            .init(shortTitle: "英语口语", text: "晚上练英语口语的时候，fan 和 fine 还是会说混，不过今天没有前几次那么挫败。"),
            .init(shortTitle: "社团开会", text: "社团今天开会分任务，我嘴上答应得很快，回头就开始担心自己做不完。"),
            .init(shortTitle: "图书馆专注", text: "下午在图书馆待的那段时间状态很好，一坐下就能进入学习。"),
            .init(shortTitle: "熬夜后果", text: "昨晚睡太晚，今天白天脑子一直不太清楚，连最简单的题目也要想很久。"),
            .init(shortTitle: "食堂胃口", text: "最近一紧张就没胃口，今天中午在食堂又是吃得很少。"),
            .init(shortTitle: "论文推进", text: "我今天终于把论文开题的结构理顺了一点，虽然还粗糙，但比前两天清楚很多。"),
            .init(shortTitle: "朋友聊天", text: "晚上和朋友聊完以后心情轻了一些，我发现我其实只是太久没把压力说出来。"),
            .init(shortTitle: "晨间刷手机", text: "今天起床以后又先刷了手机，结果真正开始做题的时候已经比计划晚了四十分钟。"),
            .init(shortTitle: "考试焦虑", text: "一想到下周的考试，我身体就会先紧一下，这种反应最近越来越明显。"),
            .init(shortTitle: "健身恢复", text: "晚上去跑了一会儿步，回来之后精神反而稳了一点，作息也没那么乱。")
        ]
    }
}

private struct SyntheticTemplate {
    let shortTitle: String
    let text: String
}
