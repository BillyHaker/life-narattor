import CoreData
import Foundation

struct AtomTagStore {
    let context: NSManagedObjectContext

    func fetchAtoms(captureID: UUID) -> [AtomItem] {
        let atomRequest = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        atomRequest.predicate = NSPredicate(format: "captureID == %@", captureID as CVarArg)
        atomRequest.sortDescriptors = [NSSortDescriptor(key: "orderInCapture", ascending: true)]

        do {
            let atoms = try context.fetch(atomRequest)
            let atomIDs = atoms.map { $0.id }
            let tagMap = fetchTagMap(atomIDs: atomIDs)

            return atoms.map { atom in
                let type = AtomType(rawValue: atom.type) ?? .event
                return AtomItem(
                    id: atom.id,
                    captureID: atom.captureID,
                    type: type,
                    content: atom.content,
                    orderInCapture: Int(atom.orderInCapture),
                    isKey: atom.isKey,
                    tags: tagMap[atom.id] ?? []
                )
            }
        } catch {
            return []
        }
    }

    func fetchTags(type: TagType? = nil) -> [TagItem] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        if let type {
            request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try context.fetch(request).map { entity in
                TagItem(
                    id: entity.id,
                    name: entity.name,
                    type: TagType(rawValue: entity.type) ?? .project,
                    isCommon: entity.isCommon
                )
            }
        } catch {
            return []
        }
    }

    func addTag(name: String, type: TagType) -> TagItem {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return TagItem(id: UUID(), name: name, type: type, isCommon: false)
        }

        if let existing = fetchTag(named: trimmed, type: type) {
            return existing
        }

        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = trimmed
        tag.type = type.rawValue
        tag.isUserVisible = true
        tag.isCommon = false
        tag.createdAt = Date()

        saveContext()

        return TagItem(id: tag.id, name: tag.name, type: type, isCommon: tag.isCommon)
    }

    func assignTag(tagID: UUID, to atomID: UUID) {
        guard !hasTag(tagID: tagID, atomID: atomID) else { return }
        let link = AtomTagEntity(context: context)
        link.id = UUID()
        link.atomID = atomID
        link.tagID = tagID
        link.createdAt = Date()
        saveContext()
    }

    func removeTag(tagID: UUID, from atomID: UUID) {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "atomID == %@ AND tagID == %@", atomID as CVarArg, tagID as CVarArg)

        if let links = try? context.fetch(request) {
            links.forEach { context.delete($0) }
            saveContext()
        }
    }

    func updateAtom(id: UUID, content: String, type: AtomType) {
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let atom = try? context.fetch(request).first else { return }
        atom.content = content
        atom.type = type.rawValue
        saveContext()
    }

    func createAtoms(from text: String, captureID: UUID) -> Int {
        let parts = text
            .split(whereSeparator: { $0 == "，" || $0 == "。" || $0 == "!" || $0 == "？" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return 0 }

        for (index, part) in parts.enumerated() {
            let atom = AtomEntity(context: context)
            atom.id = UUID()
            atom.captureID = captureID
            atom.type = AtomType.event.rawValue
            atom.content = part
            atom.orderInCapture = Int16(index)
            atom.isKey = false
            atom.createdAt = Date()
        }

        saveContext()
        return parts.count
    }

    func updateCaptureStats(captureID: UUID, atomsCount: Int, processingState: CaptureProcessingState) {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)

        guard let capture = try? context.fetch(request).first else { return }
        capture.atomsCount = Int16(atomsCount)
        capture.processingState = processingState.rawValue
        saveContext()
    }

    private func fetchTagMap(atomIDs: [UUID]) -> [UUID: [TagItem]] {
        guard !atomIDs.isEmpty else { return [:] }

        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)

        guard let links = try? context.fetch(linkRequest) else { return [:] }
        let tagIDs = links.map { $0.tagID }
        let tagRequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        tagRequest.predicate = NSPredicate(format: "id IN %@", tagIDs)

        guard let tags = try? context.fetch(tagRequest) else { return [:] }
        let tagMap = Dictionary(uniqueKeysWithValues: tags.map { tag in
            (tag.id, tag)
        })

        return links.reduce(into: [:]) { result, link in
            guard let tag = tagMap[link.tagID] else { return }
            guard tag.isUserVisible, !link.isSuggested else { return }
            let item = TagItem(
                id: tag.id,
                name: tag.name,
                type: TagType(rawValue: tag.type) ?? .project,
                isCommon: tag.isCommon,
                isSuggested: link.isSuggested,
                isUserVisible: tag.isUserVisible
            )
            result[link.atomID, default: []].append(item)
        }
    }

    private func fetchTag(named name: String, type: TagType) -> TagItem? {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "name == %@ AND type == %@", name, type.rawValue)

        guard let tag = try? context.fetch(request).first else { return nil }
        return TagItem(id: tag.id, name: tag.name, type: type, isCommon: tag.isCommon)
    }

    private func hasTag(tagID: UUID, atomID: UUID) -> Bool {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "atomID == %@ AND tagID == %@", atomID as CVarArg, tagID as CVarArg)
        return (try? context.count(for: request)) ?? 0 > 0
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
