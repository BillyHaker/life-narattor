import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeManagedObjectModel()
        container = NSPersistentContainer(name: "LifeNarratorModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let captureEntity = NSEntityDescription()
        captureEntity.name = "CaptureEntity"
        captureEntity.managedObjectClassName = NSStringFromClass(CaptureEntity.self)

        let artifactEntity = NSEntityDescription()
        artifactEntity.name = "ArtifactEntity"
        artifactEntity.managedObjectClassName = NSStringFromClass(ArtifactEntity.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        let rawTextAttribute = NSAttributeDescription()
        rawTextAttribute.name = "rawText"
        rawTextAttribute.attributeType = .stringAttributeType
        rawTextAttribute.isOptional = false

        let cleanTextAttribute = NSAttributeDescription()
        cleanTextAttribute.name = "cleanText"
        cleanTextAttribute.attributeType = .stringAttributeType
        cleanTextAttribute.isOptional = true

        let ackTitleAttribute = NSAttributeDescription()
        ackTitleAttribute.name = "ackTitle"
        ackTitleAttribute.attributeType = .stringAttributeType
        ackTitleAttribute.isOptional = true

        let ackDetailAttribute = NSAttributeDescription()
        ackDetailAttribute.name = "ackDetail"
        ackDetailAttribute.attributeType = .stringAttributeType
        ackDetailAttribute.isOptional = true

        let dayPartAttribute = NSAttributeDescription()
        dayPartAttribute.name = "dayPart"
        dayPartAttribute.attributeType = .stringAttributeType
        dayPartAttribute.isOptional = true

        let modeAttribute = NSAttributeDescription()
        modeAttribute.name = "mode"
        modeAttribute.attributeType = .stringAttributeType
        modeAttribute.isOptional = true

        captureEntity.properties = [
            idAttribute,
            createdAtAttribute,
            rawTextAttribute,
            cleanTextAttribute,
            ackTitleAttribute,
            ackDetailAttribute,
            dayPartAttribute,
            modeAttribute
        ]

        let artifactTypeAttribute = NSAttributeDescription()
        artifactTypeAttribute.name = "artifactType"
        artifactTypeAttribute.attributeType = .stringAttributeType
        artifactTypeAttribute.isOptional = false

        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false

        let contentJSONAttribute = NSAttributeDescription()
        contentJSONAttribute.name = "contentJSON"
        contentJSONAttribute.attributeType = .stringAttributeType
        contentJSONAttribute.isOptional = false

        let sourceCaptureIDAttribute = NSAttributeDescription()
        sourceCaptureIDAttribute.name = "sourceCaptureID"
        sourceCaptureIDAttribute.attributeType = .UUIDAttributeType
        sourceCaptureIDAttribute.isOptional = false

        let updatedAtAttribute = NSAttributeDescription()
        updatedAtAttribute.name = "updatedAt"
        updatedAtAttribute.attributeType = .dateAttributeType
        updatedAtAttribute.isOptional = false

        artifactEntity.properties = [
            idAttribute.copy() as! NSPropertyDescription,
            artifactTypeAttribute,
            titleAttribute,
            contentJSONAttribute,
            sourceCaptureIDAttribute,
            createdAtAttribute.copy() as! NSPropertyDescription,
            updatedAtAttribute
        ]

        model.entities = [captureEntity, artifactEntity]
        return model
    }
}
