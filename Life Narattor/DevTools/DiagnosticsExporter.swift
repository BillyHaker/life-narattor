import Foundation

struct DiagnosticsExporter {
    let storage: DebugReadableStorage
    let featureFlags: FeatureFlags
    let logStore: LogStore

    func exportDiagnosticsBundle() throws -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("diagnostics_\(timestamp)", isDirectory: true)

        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let appInfo = appInfoSnapshot()
        let flags = featureFlags.snapshot()
        let logs = logStore.entries.map { entry in
            [
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                "category": entry.category.rawValue,
                "message": entry.message
            ]
        }
        let counts = storage.fetchCounts()
        let storageSnapshot: [String: Int] = [
            "captures": counts.captures,
            "artifacts": counts.artifacts
        ]

        try writeJSON(appInfo, to: folderURL.appendingPathComponent("app_info.json"))
        try writeJSON(flags, to: folderURL.appendingPathComponent("feature_flags.json"))
        try writeJSON(logs, to: folderURL.appendingPathComponent("logs.json"))
        try writeJSON(storageSnapshot, to: folderURL.appendingPathComponent("storage_counts.json"))

        return folderURL
    }

    private func appInfoSnapshot() -> [String: String] {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        return [
            "bundle_id": bundle.bundleIdentifier ?? "",
            "version": version,
            "build": build,
            "locale": Locale.current.identifier,
            "timezone": TimeZone.current.identifier
        ]
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
}
