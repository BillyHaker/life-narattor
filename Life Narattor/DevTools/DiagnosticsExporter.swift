import Foundation

struct DiagnosticsExporter {
    let storage: DebugReadableStorage
    let featureFlags: FeatureFlags
    let logStore: LogStore

    func exportDiagnosticsBundle() throws -> URL {
        let timestamp = exportTimestamp()
        let baseURL = try diagnosticsFolderURL()
        let folderURL = baseURL.appendingPathComponent("diagnostics_\(timestamp)", isDirectory: true)
        let latestURL = baseURL.appendingPathComponent("latest", isDirectory: true)

        try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
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
        let transcriptionDebug = TranscriptionDebugStore.shared.events.map { event in
            [
                "timestamp": ISO8601DateFormatter().string(from: event.timestamp),
                "phase": event.phase,
                "status": event.status,
                "provider": event.provider,
                "capture_id": event.captureID ?? "",
                "code": event.code ?? "",
                "message": event.message ?? ""
            ]
        }

        try writeJSON(appInfo, to: folderURL.appendingPathComponent("app_info.json"))
        try writeJSON(flags, to: folderURL.appendingPathComponent("feature_flags.json"))
        try writeJSON(logs, to: folderURL.appendingPathComponent("logs.json"))
        try writeJSON(storageSnapshot, to: folderURL.appendingPathComponent("storage_counts.json"))
        try writeJSON(transcriptionDebug, to: folderURL.appendingPathComponent("transcription_debug.json"))

        try replaceLatestFolder(from: folderURL, to: latestURL)
        saveLatestPath(latestURL.path)

        return folderURL
    }

    private func diagnosticsFolderURL() throws -> URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "DiagnosticsExporter", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "无法获取文档目录"
            ])
        }

        return documents.appendingPathComponent("Diagnostics", isDirectory: true)
    }

    private func exportTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

    private func replaceLatestFolder(from sourceURL: URL, to latestURL: URL) throws {
        let manager = FileManager.default
        if manager.fileExists(atPath: latestURL.path) {
            try manager.removeItem(at: latestURL)
        }
        try manager.copyItem(at: sourceURL, to: latestURL)
    }

    private func saveLatestPath(_ path: String) {
        UserDefaults.standard.set(path, forKey: "devtools.latestDiagnosticsPath")
    }

    static func latestPath() -> String? {
        UserDefaults.standard.string(forKey: "devtools.latestDiagnosticsPath")
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
