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

        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        loadPersistentStores()

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        seedVisibleTagLibraryIfNeeded()
    }

    private func loadPersistentStores() {
        container.loadPersistentStores { [container] description, error in
            if let error = error as NSError? {
                guard let storeURL = description.url else {
                    assertionFailure("Unresolved error \(error), \(error.userInfo)")
                    return
                }

                do {
                    try container.persistentStoreCoordinator.destroyPersistentStore(
                        at: storeURL,
                        ofType: NSSQLiteStoreType,
                        options: description.options
                    )
                    container.loadPersistentStores { _, retryError in
                        if let retryError = retryError as NSError? {
                            assertionFailure("Unresolved error \(retryError), \(retryError.userInfo)")
                        }
                    }
                } catch let error as NSError {
                    assertionFailure("Unresolved error \(error), \(error.userInfo)")
                } catch {
                    assertionFailure("Unresolved error \(error)")
                }
            }
        }
    }

    private func seedVisibleTagLibraryIfNeeded() {
        let context = container.viewContext
        context.performAndWait {
            let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
            let existingTags = (try? context.fetch(request)) ?? []
            let existingKeys = Set(existingTags.map { "\($0.type)|\($0.name.lowercased())" })

            let seeds = Self.defaultVisibleTagSeeds
            var inserted = false

            for seed in seeds {
                let key = "\(seed.type.rawValue)|\(seed.name.lowercased())"
                guard !existingKeys.contains(key) else { continue }
                let tag = TagEntity(context: context)
                tag.id = UUID()
                tag.name = seed.name
                tag.type = seed.type.rawValue
                tag.isUserVisible = true
                tag.isCommon = seed.isCommon
                tag.createdAt = Date()
                inserted = true
            }

            if inserted {
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
        }
    }

    private static let defaultVisibleTagSeeds: [(type: TagType, name: String, isCommon: Bool)] = [
        (.project, "Life Narrator", true),
        (.project, "英语口语", true),
        (.project, "健身计划", false),
        (.project, "求职准备", false),
        (.project, "内容创作", false),

        (.habit, "早起", true),
        (.habit, "晨间启动", true),
        (.habit, "深度工作", true),
        (.habit, "晚间复盘", false),
        (.habit, "运动打卡", false),
        (.habit, "刷手机", false),
        (.habit, "拖延", false),
        (.habit, "规律吃饭", false),

        (.theme, "工作安排", true),
        (.theme, "发音训练", true),
        (.theme, "情绪波动", false),
        (.theme, "时间管理", false),
        (.theme, "睡眠", false),
        (.theme, "饮食", false),
        (.theme, "执行力", false),
        (.theme, "自我怀疑", false),

        (.person, "新老板", true),
        (.person, "同事", false),
        (.person, "家人", false),
        (.person, "朋友", false),

        (.goal, "提升英语表达", true),
        (.goal, "建立稳定作息", false),
        (.goal, "提高专注力", false),
        (.goal, "改善工作状态", false),
        (.goal, "减少拖延", false),

        (.context, "公司", true),
        (.context, "家里", true),
        (.context, "通勤", false),
        (.context, "晨间", true),
        (.context, "晚上", false),
        (.context, "周末", false)
    ]

    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let captureEntity = NSEntityDescription()
        captureEntity.name = "CaptureEntity"
        captureEntity.managedObjectClassName = NSStringFromClass(CaptureEntity.self)

        let artifactEntity = NSEntityDescription()
        artifactEntity.name = "ArtifactEntity"
        artifactEntity.managedObjectClassName = NSStringFromClass(ArtifactEntity.self)

        let atomEntity = NSEntityDescription()
        atomEntity.name = "AtomEntity"
        atomEntity.managedObjectClassName = NSStringFromClass(AtomEntity.self)

        let tagEntity = NSEntityDescription()
        tagEntity.name = "TagEntity"
        tagEntity.managedObjectClassName = NSStringFromClass(TagEntity.self)

        let atomTagEntity = NSEntityDescription()
        atomTagEntity.name = "AtomTagEntity"
        atomTagEntity.managedObjectClassName = NSStringFromClass(AtomTagEntity.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        let isHiddenFromFeedAttribute = NSAttributeDescription()
        isHiddenFromFeedAttribute.name = "isHiddenFromFeed"
        isHiddenFromFeedAttribute.attributeType = .booleanAttributeType
        isHiddenFromFeedAttribute.isOptional = false
        isHiddenFromFeedAttribute.defaultValue = false

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

        let atomsCountAttribute = NSAttributeDescription()
        atomsCountAttribute.name = "atomsCount"
        atomsCountAttribute.attributeType = .integer16AttributeType
        atomsCountAttribute.isOptional = false
        atomsCountAttribute.defaultValue = 0

        let processingStateAttribute = NSAttributeDescription()
        processingStateAttribute.name = "processingState"
        processingStateAttribute.attributeType = .stringAttributeType
        processingStateAttribute.isOptional = true

        let inputTypeAttribute = NSAttributeDescription()
        inputTypeAttribute.name = "inputType"
        inputTypeAttribute.attributeType = .stringAttributeType
        inputTypeAttribute.isOptional = true

        let audioPathAttribute = NSAttributeDescription()
        audioPathAttribute.name = "audioPath"
        audioPathAttribute.attributeType = .stringAttributeType
        audioPathAttribute.isOptional = true

        let transcriptAttribute = NSAttributeDescription()
        transcriptAttribute.name = "transcriptText"
        transcriptAttribute.attributeType = .stringAttributeType
        transcriptAttribute.isOptional = true

        let transcriptionStatusAttribute = NSAttributeDescription()
        transcriptionStatusAttribute.name = "transcriptionStatus"
        transcriptionStatusAttribute.attributeType = .stringAttributeType
        transcriptionStatusAttribute.isOptional = true

        let transcriptionErrorAttribute = NSAttributeDescription()
        transcriptionErrorAttribute.name = "transcriptionError"
        transcriptionErrorAttribute.attributeType = .stringAttributeType
        transcriptionErrorAttribute.isOptional = true

        let atomizationErrorAttribute = NSAttributeDescription()
        atomizationErrorAttribute.name = "atomizationError"
        atomizationErrorAttribute.attributeType = .stringAttributeType
        atomizationErrorAttribute.isOptional = true

        let sourceThreadIDAttribute = NSAttributeDescription()
        sourceThreadIDAttribute.name = "sourceThreadID"
        sourceThreadIDAttribute.attributeType = .UUIDAttributeType
        sourceThreadIDAttribute.isOptional = true

        let atomizeVersionAttribute = NSAttributeDescription()
        atomizeVersionAttribute.name = "atomizeVersion"
        atomizeVersionAttribute.attributeType = .stringAttributeType
        atomizeVersionAttribute.isOptional = true

        captureEntity.properties = [
            idAttribute,
            createdAtAttribute,
            isHiddenFromFeedAttribute,
            rawTextAttribute,
            cleanTextAttribute,
            ackTitleAttribute,
            ackDetailAttribute,
            dayPartAttribute,
            modeAttribute,
            atomsCountAttribute,
            processingStateAttribute,
            inputTypeAttribute,
            audioPathAttribute,
            transcriptAttribute,
            transcriptionStatusAttribute,
            transcriptionErrorAttribute,
            atomizationErrorAttribute,
            sourceThreadIDAttribute,
            atomizeVersionAttribute
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

        let artifactIdAttribute = NSAttributeDescription()
        artifactIdAttribute.name = "id"
        artifactIdAttribute.attributeType = .UUIDAttributeType
        artifactIdAttribute.isOptional = false

        let artifactStatusAttribute = NSAttributeDescription()
        artifactStatusAttribute.name = "status"
        artifactStatusAttribute.attributeType = .stringAttributeType
        artifactStatusAttribute.isOptional = false
        artifactStatusAttribute.defaultValue = AssistArchiveStatus.draft.rawValue

        let artifactCreatedAtAttribute = NSAttributeDescription()
        artifactCreatedAtAttribute.name = "createdAt"
        artifactCreatedAtAttribute.attributeType = .dateAttributeType
        artifactCreatedAtAttribute.isOptional = false

        artifactEntity.properties = [
            artifactIdAttribute,
            artifactTypeAttribute,
            titleAttribute,
            contentJSONAttribute,
            sourceCaptureIDAttribute,
            artifactStatusAttribute,
            artifactCreatedAtAttribute,
            updatedAtAttribute
        ]

        let atomIdAttribute = NSAttributeDescription()
        atomIdAttribute.name = "id"
        atomIdAttribute.attributeType = .UUIDAttributeType
        atomIdAttribute.isOptional = false

        let atomCaptureIdAttribute = NSAttributeDescription()
        atomCaptureIdAttribute.name = "captureID"
        atomCaptureIdAttribute.attributeType = .UUIDAttributeType
        atomCaptureIdAttribute.isOptional = false

        let atomTypeAttribute = NSAttributeDescription()
        atomTypeAttribute.name = "type"
        atomTypeAttribute.attributeType = .stringAttributeType
        atomTypeAttribute.isOptional = false

        let atomContentAttribute = NSAttributeDescription()
        atomContentAttribute.name = "content"
        atomContentAttribute.attributeType = .stringAttributeType
        atomContentAttribute.isOptional = false

        let atomOrderAttribute = NSAttributeDescription()
        atomOrderAttribute.name = "orderInCapture"
        atomOrderAttribute.attributeType = .integer16AttributeType
        atomOrderAttribute.isOptional = false

        let atomIsKeyAttribute = NSAttributeDescription()
        atomIsKeyAttribute.name = "isKey"
        atomIsKeyAttribute.attributeType = .booleanAttributeType
        atomIsKeyAttribute.isOptional = false
        atomIsKeyAttribute.defaultValue = false

        let atomCreatedAtAttribute = NSAttributeDescription()
        atomCreatedAtAttribute.name = "createdAt"
        atomCreatedAtAttribute.attributeType = .dateAttributeType
        atomCreatedAtAttribute.isOptional = false

        let atomStartCharAttribute = NSAttributeDescription()
        atomStartCharAttribute.name = "startChar"
        atomStartCharAttribute.attributeType = .integer16AttributeType
        atomStartCharAttribute.isOptional = false
        atomStartCharAttribute.defaultValue = Int16(-1)

        let atomEndCharAttribute = NSAttributeDescription()
        atomEndCharAttribute.name = "endChar"
        atomEndCharAttribute.attributeType = .integer16AttributeType
        atomEndCharAttribute.isOptional = false
        atomEndCharAttribute.defaultValue = Int16(-1)

        let atomVersionAttribute = NSAttributeDescription()
        atomVersionAttribute.name = "atomizeVersion"
        atomVersionAttribute.attributeType = .stringAttributeType
        atomVersionAttribute.isOptional = true

        atomEntity.properties = [
            atomIdAttribute,
            atomCaptureIdAttribute,
            atomTypeAttribute,
            atomContentAttribute,
            atomOrderAttribute,
            atomIsKeyAttribute,
            atomCreatedAtAttribute,
            atomStartCharAttribute,
            atomEndCharAttribute,
            atomVersionAttribute
        ]

        let tagIdAttribute = NSAttributeDescription()
        tagIdAttribute.name = "id"
        tagIdAttribute.attributeType = .UUIDAttributeType
        tagIdAttribute.isOptional = false

        let tagNameAttribute = NSAttributeDescription()
        tagNameAttribute.name = "name"
        tagNameAttribute.attributeType = .stringAttributeType
        tagNameAttribute.isOptional = false

        let tagTypeAttribute = NSAttributeDescription()
        tagTypeAttribute.name = "type"
        tagTypeAttribute.attributeType = .stringAttributeType
        tagTypeAttribute.isOptional = false

        let tagVisibleAttribute = NSAttributeDescription()
        tagVisibleAttribute.name = "isUserVisible"
        tagVisibleAttribute.attributeType = .booleanAttributeType
        tagVisibleAttribute.isOptional = false
        tagVisibleAttribute.defaultValue = true

        let tagCommonAttribute = NSAttributeDescription()
        tagCommonAttribute.name = "isCommon"
        tagCommonAttribute.attributeType = .booleanAttributeType
        tagCommonAttribute.isOptional = false
        tagCommonAttribute.defaultValue = false

        let tagCreatedAtAttribute = NSAttributeDescription()
        tagCreatedAtAttribute.name = "createdAt"
        tagCreatedAtAttribute.attributeType = .dateAttributeType
        tagCreatedAtAttribute.isOptional = false

        tagEntity.properties = [
            tagIdAttribute,
            tagNameAttribute,
            tagTypeAttribute,
            tagVisibleAttribute,
            tagCommonAttribute,
            tagCreatedAtAttribute
        ]

        let linkIdAttribute = NSAttributeDescription()
        linkIdAttribute.name = "id"
        linkIdAttribute.attributeType = .UUIDAttributeType
        linkIdAttribute.isOptional = false

        let linkAtomIdAttribute = NSAttributeDescription()
        linkAtomIdAttribute.name = "atomID"
        linkAtomIdAttribute.attributeType = .UUIDAttributeType
        linkAtomIdAttribute.isOptional = false

        let linkTagIdAttribute = NSAttributeDescription()
        linkTagIdAttribute.name = "tagID"
        linkTagIdAttribute.attributeType = .UUIDAttributeType
        linkTagIdAttribute.isOptional = false

        let linkCreatedAtAttribute = NSAttributeDescription()
        linkCreatedAtAttribute.name = "createdAt"
        linkCreatedAtAttribute.attributeType = .dateAttributeType
        linkCreatedAtAttribute.isOptional = false

        let linkSuggestedAttribute = NSAttributeDescription()
        linkSuggestedAttribute.name = "isSuggested"
        linkSuggestedAttribute.attributeType = .booleanAttributeType
        linkSuggestedAttribute.isOptional = false
        linkSuggestedAttribute.defaultValue = false

        atomTagEntity.properties = [
            linkIdAttribute,
            linkAtomIdAttribute,
            linkTagIdAttribute,
            linkCreatedAtAttribute,
            linkSuggestedAttribute
        ]

        model.entities = [captureEntity, artifactEntity, atomEntity, tagEntity, atomTagEntity]
        return model
    }
}
