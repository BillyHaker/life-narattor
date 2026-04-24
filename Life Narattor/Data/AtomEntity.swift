import CoreData

@objc(AtomEntity)
final class AtomEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var captureID: UUID
    @NSManaged var type: String
    @NSManaged var content: String
    @NSManaged var orderInCapture: Int16
    @NSManaged var isKey: Bool
    @NSManaged var createdAt: Date
    @NSManaged var startChar: Int16 // -1 if offset not available
    @NSManaged var endChar: Int16 // -1 if offset not available
    @NSManaged var atomizeVersion: String? // e.g. "atom_v1"
}
