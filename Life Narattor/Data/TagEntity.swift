import CoreData

@objc(TagEntity)
final class TagEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var isUserVisible: Bool
    @NSManaged var isCommon: Bool
    @NSManaged var createdAt: Date
}
