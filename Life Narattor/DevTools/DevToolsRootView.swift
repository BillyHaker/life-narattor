import SwiftUI

struct DevToolsRootView: View {
    let storage: DebugReadableStorage

    @State private var featureFlags = FeatureFlags.shared
    @State private var logStore = LogStore.shared

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
                NavigationLink("Diagnostics Export") {
                    DevToolsDiagnosticsView(storage: storage, featureFlags: featureFlags, logStore: logStore)
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
    @State var featureFlags: FeatureFlags

    var body: some View {
        List {
            Toggle("Mock AI", isOn: $featureFlags.isMockAIEnabled)
            Toggle("Verbose Logging", isOn: $featureFlags.isVerboseLoggingEnabled)
            Toggle("Network Recording", isOn: $featureFlags.isNetworkRecordingEnabled)
            Toggle("Seed Sample Data", isOn: $featureFlags.isSeedSampleDataEnabled)
        }
        .navigationTitle("Feature Flags")
    }
}

struct DevToolsLogsView: View {
    @State var logStore: LogStore

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

struct DevToolsDiagnosticsView: View {
    let storage: DebugReadableStorage
    let featureFlags: FeatureFlags
    let logStore: LogStore

    @State private var exportURL: URL?
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
            } else {
                Button("生成诊断包") {
                    do {
                        exportURL = try DiagnosticsExporter(
                            storage: storage,
                            featureFlags: featureFlags,
                            logStore: logStore
                        ).exportDiagnosticsBundle()
                    } catch {
                        exportError = error.localizedDescription
                    }
                }
                .buttonStyle(.borderedProminent)
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
