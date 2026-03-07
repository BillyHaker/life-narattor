import CoreData

@objc(ArtifactEntity)
final class ArtifactEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var artifactType: String
    @NSManaged var title: String
    @NSManaged var contentJSON: String
    @NSManaged var sourceCaptureID: UUID
    @NSManaged var status: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
}
