import CoreData

@objc(CaptureEntity)
final class CaptureEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var createdAt: Date
    @NSManaged var rawText: String
    @NSManaged var cleanText: String?
    @NSManaged var ackTitle: String?
    @NSManaged var ackDetail: String?
    @NSManaged var dayPart: String?
    @NSManaged var mode: String?
    @NSManaged var atomsCount: Int16
    @NSManaged var processingState: String?
    @NSManaged var inputType: String?
    @NSManaged var audioPath: String?
    @NSManaged var transcriptText: String?
    @NSManaged var transcriptionStatus: String?
}
