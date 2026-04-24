import CoreData

@objc(AtomTagEntity)
final class AtomTagEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var atomID: UUID
    @NSManaged var tagID: UUID
    @NSManaged var createdAt: Date
    @NSManaged var isSuggested: Bool
}
