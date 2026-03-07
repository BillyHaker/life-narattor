import Foundation
import Observation

@Observable
final class LogStore {
    static let shared = LogStore()

    private let maxEntries = 500
    private(set) var entries: [LogEntry] = []

    func log(_ message: String, category: LogCategory) {
        let entry = LogEntry(id: UUID(), timestamp: Date(), category: category, message: message)
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    func clear() {
        entries.removeAll()
    }
}

struct LogEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let category: LogCategory
    let message: String
}

enum LogCategory: String, CaseIterable, Identifiable {
    case ui
    case db
    case network
    case ai
    case jobs

    var id: String { rawValue }

    var title: String {
        rawValue.uppercased()
    }
}
