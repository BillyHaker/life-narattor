import CoreData
import SwiftUI
import UIKit

struct DevToolsRootView: View {
    let storage: DebugReadableStorage
    let context: NSManagedObjectContext
    let aiService: AIService

    @StateObject private var featureFlags = FeatureFlags.shared
    @StateObject private var logStore = LogStore.shared
    @StateObject private var transcriptionDebugStore = TranscriptionDebugStore.shared

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("App Info") {
                    DevToolsAppInfoView()
                }
                NavigationLink("Feature Flags") {
                    DevToolsFeatureFlagsView(featureFlags: featureFlags)
                }
                NavigationLink("Logs") {
                    DevToolsLogsView(logStore: logStore)
                }
                NavigationLink("Storage") {
                    DevToolsStorageView(storage: storage)
                }
                NavigationLink("AI Connection Test") {
                    DevToolsAIConnectionTestView()
                }
                NavigationLink("AI Debug") {
                    DevToolsAIDebugView()
                }
                NavigationLink("Transcription Debug") {
                    DevToolsTranscriptionDebugView(store: transcriptionDebugStore, featureFlags: featureFlags)
                }
                NavigationLink("All Tags") {
                    DevToolsTagsView(context: context, aiService: aiService)
                }
                NavigationLink("Review Material Debug") {
                    DevToolsReviewMaterialView(context: context)
                }
                NavigationLink("Diagnostics Export") {
                    DevToolsDiagnosticsView(storage: storage, featureFlags: featureFlags, logStore: logStore)
                }
                NavigationLink("Synthetic Records") {
                    DevToolsSyntheticRecordsView(context: context)
                }
            }
            .navigationTitle("DevTools")
        }
    }
}

struct DevToolsAppInfoView: View {
    var body: some View {
        List {
            DevToolsInfoRow(title: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "")
            DevToolsInfoRow(title: "Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
            DevToolsInfoRow(title: "Build", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")
            DevToolsInfoRow(title: "Locale", value: Locale.current.identifier)
            DevToolsInfoRow(title: "Time Zone", value: TimeZone.current.identifier)
        }
        .navigationTitle("App Info")
    }
}

struct DevToolsFeatureFlagsView: View {
    @ObservedObject var featureFlags: FeatureFlags

    var body: some View {
        List {
            Toggle("Verbose Logging", isOn: $featureFlags.isVerboseLoggingEnabled)
            Toggle("Network Recording", isOn: $featureFlags.isNetworkRecordingEnabled)
            Toggle("Seed Sample Data", isOn: $featureFlags.isSeedSampleDataEnabled)
            Toggle("Simulate Transcription Failure", isOn: $featureFlags.isTranscriptionFailureSimulated)
            Toggle("Simulate Transcription Offline", isOn: $featureFlags.isTranscriptionOfflineSimulated)
            Toggle("Prefer AI Transcription", isOn: $featureFlags.isAITranscriptionPreferred)
        }
        .navigationTitle("Feature Flags")
    }
}

struct DevToolsLogsView: View {
    @ObservedObject var logStore: LogStore

    var body: some View {
        List {
            ForEach(logStore.entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.category.title) · \(entry.timestamp.formatted(date: .numeric, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.message)
                        .font(.body)
                }
            }
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    logStore.clear()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Add Test Log") {
                    logStore.log("Test log entry", category: .ai)
                }
            }
        }
    }
}

struct DevToolsStorageView: View {
    let storage: DebugReadableStorage

    var body: some View {
        let counts = storage.fetchCounts()
        return List {
            DevToolsInfoRow(title: "Captures", value: "\(counts.captures)")
            DevToolsInfoRow(title: "Artifacts", value: "\(counts.artifacts)")
        }
        .navigationTitle("Storage")
    }
}

struct DevToolsAIConnectionTestView: View {
    @State private var status: String = "尚未测试"
    @State private var isRunning = false
    @State private var keyInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("连接状态：\(status)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("环境变量")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("OPENAI_API_KEY：\(keyStatus)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("LIFENARRATOR_AI_BASE：\(baseStatus)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("临时 Key（仅本机）")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                SecureField("粘贴 OpenAI API Key", text: $keyInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 12) {
                    Button("保存到 Keychain") {
                        saveKey()
                    }
                    .buttonStyle(.bordered)

                    Button("清除 Keychain") {
                        clearKey()
                    }
                    .buttonStyle(.bordered)
                }
            }

            Button(isRunning ? "测试中…" : "测试 OpenAI 连接") {
                runTest()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)

            Text("提示：需要在 Scheme 环境变量中设置 OPENAI_API_KEY 才会调用真实服务。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .navigationTitle("AI Connection Test")
    }

    private var keyStatus: String {
        let envValue = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        if !envValue.isEmpty {
            let suffix = String(envValue.suffix(4))
            return "已设置（末四位 \(suffix)）"
        }
        if let stored = KeychainStore.get("OPENAI_API_KEY"), !stored.isEmpty {
            let suffix = String(stored.suffix(4))
            return "已设置（Keychain 末四位 \(suffix)）"
        }
        return "未设置"
    }

    private var baseStatus: String {
        let value = ProcessInfo.processInfo.environment["LIFENARRATOR_AI_BASE"] ?? ""
        return value.isEmpty ? "未设置" : value
    }

    private func runTest() {
        isRunning = true
        status = "请求中…"

        let sample = CaptureItem(
            id: UUID(),
            createdAt: Date(),
            rawText: "今天完成了一个小目标",
            cleanText: "今天完成了一个小目标",
            ackTitle: nil,
            ackDetail: nil,
            dayPart: .morning,
            mode: .log,
            assistRecord: nil,
            atomsCount: 0,
            processingState: .cleanReady,
            inputType: .text,
            audioPath: nil,
            transcriptText: nil,
            transcriptionStatus: nil,
            isTranscriptionActive: false
        )

        Task {
            defer { isRunning = false }
            guard let apiKey = OpenAIConfig.apiKey, !apiKey.isEmpty else {
                status = "未配置 OpenAI Key"
                return
            }
            do {
                let aiService = OpenAIService(apiKey: apiKey)
                _ = try await aiService.quickAck(for: sample)
                status = "连接成功（OpenAI）"
            } catch {
                status = "连接失败：\(error.localizedDescription)"
            }
        }
    }

    private func saveKey() {
        let trimmed = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if KeychainStore.set(trimmed, for: "OPENAI_API_KEY") {
            status = "已保存 Keychain"
            keyInput = ""
        } else {
            status = "保存失败"
        }
    }

    private func clearKey() {
        _ = KeychainStore.delete("OPENAI_API_KEY")
        status = "已清除 Keychain"
    }
}

struct DevToolsTranscriptionDebugView: View {
    @ObservedObject var store: TranscriptionDebugStore
    @ObservedObject var featureFlags: FeatureFlags

    var body: some View {
        List {
            Section("当前路径") {
                DevToolsInfoRow(title: "Primary", value: store.primaryProviderLabel(featureFlags: featureFlags))
                DevToolsInfoRow(title: "Pipeline", value: pipelineLabel)
                DevToolsInfoRow(title: "AI Preferred", value: featureFlags.isAITranscriptionPreferred ? "ON" : "OFF")
            }

            Section("最近状态") {
                if let latest = store.latestEvent {
                    DevToolsInfoRow(
                        title: "Latest",
                        value: "\(latest.phase) · \(latest.status) · \(latest.timestamp.formatted(date: .omitted, time: .standard))"
                    )
                } else {
                    Text("暂无转写调试记录")
                        .foregroundStyle(.secondary)
                }
                DevToolsInfoRow(title: "Last Error Code", value: store.lastErrorCode ?? "-")
                DevToolsInfoRow(title: "Last Fallback", value: store.lastFallbackReason ?? "-")
            }

            Section("最近事件") {
                if store.events.isEmpty {
                    Text("暂无事件")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(store.events.prefix(50))) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.phase) · \(entry.status)")
                                .font(.subheadline.weight(.semibold))
                            Text("\(entry.provider) · \(entry.timestamp.formatted(date: .numeric, time: .standard))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let code = entry.code {
                                Text("code: \(code)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if let message = entry.message, !message.isEmpty {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Transcription Debug")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    store.clear()
                }
            }
        }
    }

    private var pipelineLabel: String {
        let primary = store.primaryProviderLabel(featureFlags: featureFlags)
        if featureFlags.isAITranscriptionPreferred {
            return "\(primary) -> local.speech(fallback)"
        }
        return "local.speech"
    }
}

struct DevToolsDiagnosticsView: View {
    let storage: DebugReadableStorage
    let featureFlags: FeatureFlags
    let logStore: LogStore

    @State private var exportURL: URL?
    @State private var latestPath: String? = DiagnosticsExporter.latestPath()
    @State private var exportError: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("导出诊断包（DEBUG）")
                .font(.headline)

            if let exportURL {
                ShareLink(item: exportURL) {
                    Text("分享诊断包")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("保存路径")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(exportURL.path)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)

                    Button("复制路径") {
                        UIPasteboard.general.string = exportURL.path
                    }
                    .font(.footnote.weight(.semibold))
                }
            } else {
                Button("生成诊断包") {
                    do {
                        exportURL = try DiagnosticsExporter(
                            storage: storage,
                            featureFlags: featureFlags,
                            logStore: logStore
                        ).exportDiagnosticsBundle()
                        latestPath = DiagnosticsExporter.latestPath()
                    } catch {
                        exportError = error.localizedDescription
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let latestPath {
                VStack(alignment: .leading, spacing: 6) {
                    Text("最新诊断包")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(latestPath)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                    Button("复制最新路径") {
                        UIPasteboard.general.string = latestPath
                    }
                    .font(.footnote.weight(.semibold))
                }
            }

            if let exportError {
                Text(exportError)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .navigationTitle("Diagnostics")
    }
}

struct DevToolsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.body)
    }
}
