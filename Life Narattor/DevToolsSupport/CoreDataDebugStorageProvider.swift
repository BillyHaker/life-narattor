import CoreData

struct CoreDataDebugStorageProvider: DebugReadableStorage {
    let context: NSManagedObjectContext

    func fetchCounts() -> DebugStorageCounts {
        let capturesRequest = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        let artifactsRequest = NSFetchRequest<ArtifactEntity>(entityName: "ArtifactEntity")

        let captures = (try? context.count(for: capturesRequest)) ?? 0
        let artifacts = (try? context.count(for: artifactsRequest)) ?? 0

        return DebugStorageCounts(captures: captures, artifacts: artifacts)
    }
}
