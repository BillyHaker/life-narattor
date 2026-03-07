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
}
