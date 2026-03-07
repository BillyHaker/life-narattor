import Foundation

protocol DebugReadableStorage {
    func fetchCounts() -> DebugStorageCounts
}

struct DebugStorageCounts {
    let captures: Int
    let artifacts: Int
}
