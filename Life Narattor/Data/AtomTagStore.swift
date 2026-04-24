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
                let startChar = atom.startChar >= 0 ? Int(atom.startChar) : nil
                let endChar = atom.endChar >= 0 ? Int(atom.endChar) : nil
                return AtomItem(
                    id: atom.id,
                    captureID: atom.captureID,
                    type: type,
                    content: atom.content,
                    orderInCapture: Int(atom.orderInCapture),
                    isKey: atom.isKey,
                    tags: tagMap[atom.id] ?? [],
                    startChar: startChar,
                    endChar: endChar,
                    atomizeVersion: atom.atomizeVersion
                )
            }
        } catch {
            return []
        }
    }

    func fetchTags(type: TagType? = nil) -> [TagItem] {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        if let type {
            request.predicate = NSPredicate(format: "type == %@ AND isUserVisible == YES", type.rawValue)
        } else {
            request.predicate = NSPredicate(format: "isUserVisible == YES")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try context.fetch(request).map { entity in
                TagItem(
                    id: entity.id,
                    name: entity.name,
                    type: TagType(rawValue: entity.type) ?? .project,
                    isCommon: entity.isCommon,
                    isSuggested: false,
                    isUserVisible: entity.isUserVisible
                )
            }
        } catch {
            return []
        }
    }

    func addTag(name: String, type: TagType) -> TagItem {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return TagItem(id: UUID(), name: name, type: type, isCommon: false, isSuggested: false, isUserVisible: true)
        }

        if let existing = fetchTagEntity(named: trimmed, type: type) {
            if !existing.isUserVisible {
                existing.isUserVisible = true
                saveContext()
            }
            return TagItem(id: existing.id, name: existing.name, type: type, isCommon: existing.isCommon, isSuggested: false, isUserVisible: true)
        }

        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = trimmed
        tag.type = type.rawValue
        tag.isUserVisible = true
        tag.isCommon = false
        tag.createdAt = Date()

        saveContext()

        return TagItem(id: tag.id, name: tag.name, type: type, isCommon: tag.isCommon, isSuggested: false, isUserVisible: true)
    }

    func assignTag(tagID: UUID, to atomID: UUID, isSuggested: Bool = false) {
        guard !hasTag(tagID: tagID, atomID: atomID) else { return }
        let link = AtomTagEntity(context: context)
        link.id = UUID()
        link.atomID = atomID
        link.tagID = tagID
        link.createdAt = Date()
        link.isSuggested = isSuggested
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

    func markAsKey(atomID: UUID) {
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        request.predicate = NSPredicate(format: "id == %@", atomID as CVarArg)

        guard let atom = try? context.fetch(request).first else { return }
        atom.isKey = true
        saveContext()
    }

    func deleteAtom(atomID: UUID) {
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        request.predicate = NSPredicate(format: "id == %@", atomID as CVarArg)

        guard let atom = try? context.fetch(request).first else { return }

        // Remove associated tags
        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID == %@", atomID as CVarArg)
        if let links = try? context.fetch(linkRequest) {
            links.forEach { context.delete($0) }
        }

        // Delete atom (V1: hard delete; V2: could add deletedAt field for soft delete)
        context.delete(atom)
        saveContext()
    }

    func confirmSuggestedTag(atomID: UUID, tagID: UUID) {
        if let tag = fetchTagEntity(by: tagID), !tag.isUserVisible {
            tag.isUserVisible = true
        }
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "atomID == %@ AND tagID == %@", atomID as CVarArg, tagID as CVarArg)
        guard let link = try? context.fetch(request).first else { return }
        guard link.isSuggested else { return }
        link.isSuggested = false
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
            atom.startChar = -1
            atom.endChar = -1
            atom.atomizeVersion = "fallback_v1"
        }

        saveContext()
        return parts.count
    }

    func replaceAtoms(with drafts: [AtomDraft], captureID: UUID, atomizeVersion: String?) -> [UUID] {
        clearAtoms(captureID: captureID)
        var createdIDs: [UUID] = []
        for (index, draft) in drafts.enumerated() {
            let atom = AtomEntity(context: context)
            atom.id = UUID()
            atom.captureID = captureID
            atom.type = draft.type.rawValue
            atom.content = draft.content
            atom.orderInCapture = Int16(index)
            atom.isKey = false
            atom.createdAt = Date()
            atom.startChar = Int16(draft.startChar ?? -1)
            atom.endChar = Int16(draft.endChar ?? -1)
            atom.atomizeVersion = atomizeVersion
            createdIDs.append(atom.id)
        }
        saveContext()
        return createdIDs
    }

    func clearAtomsForCapture(captureID: UUID) {
        clearAtoms(captureID: captureID)
        saveContext()
    }

    func clearSuggestedTags(for atomIDs: [UUID]) {
        guard !atomIDs.isEmpty else { return }
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "atomID IN %@ AND isSuggested == YES", atomIDs)
        if let links = try? context.fetch(request) {
            links.forEach { context.delete($0) }
            saveContext()
        }
    }

    func createAtoms(fromArchive payload: AssistArchivePayload, captureID: UUID) -> [UUID] {
        var createdIDs: [UUID] = []
        var order = 0

        let units = payload.card.effectiveRecordUnits
        if !units.isEmpty {
            for unit in units {
                let atom = AtomEntity(context: context)
                atom.id = UUID()
                atom.captureID = captureID
                atom.type = AtomType.event.rawValue
                atom.content = atomContent(from: unit)
                atom.orderInCapture = Int16(order)
                atom.isKey = false
                atom.createdAt = Date()
                atom.startChar = -1
                atom.endChar = -1
                atom.atomizeVersion = "assist_record_units_v1"
                createdIDs.append(atom.id)
                order += 1
            }
        } else {
            for point in payload.card.keyPoints.prefix(3) {
                let atom = AtomEntity(context: context)
                atom.id = UUID()
                atom.captureID = captureID
                atom.type = AtomType.insight.rawValue
                atom.content = point
                atom.orderInCapture = Int16(order)
                atom.isKey = false
                atom.createdAt = Date()
                atom.startChar = -1
                atom.endChar = -1
                atom.atomizeVersion = "assist_archive_v1"
                createdIDs.append(atom.id)
                order += 1
            }

            for step in payload.card.nextSteps.prefix(3) {
                let atom = AtomEntity(context: context)
                atom.id = UUID()
                atom.captureID = captureID
                atom.type = AtomType.action.rawValue
                atom.content = step
                atom.orderInCapture = Int16(order)
                atom.isKey = false
                atom.createdAt = Date()
                atom.startChar = -1
                atom.endChar = -1
                atom.atomizeVersion = "assist_archive_v1"
                createdIDs.append(atom.id)
                order += 1
            }
        }

        saveContext()
        return createdIDs
    }

    private func atomContent(from unit: AssistRecordUnit) -> String {
        let summary = unit.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        if !summary.isEmpty {
            return "\(unit.title)：\(summary)"
        }
        if let firstPoint = unit.keyPoints.first {
            return "\(unit.title)：\(firstPoint)"
        }
        if let firstStep = unit.nextSteps.first {
            return "\(unit.title)：\(firstStep)"
        }
        return unit.title
    }

    func assignTagSuggestions(_ suggestions: [AssistTagSuggestion], to atomIDs: [UUID]) {
        guard !suggestions.isEmpty else { return }
        for suggestion in suggestions.prefix(3) {
            guard let type = TagType(rawValue: suggestion.tagType) else { continue }
            let tag = addTag(name: suggestion.name, type: type)
            for atomID in atomIDs {
                assignTag(tagID: tag.id, to: atomID, isSuggested: true)
            }
        }
    }

    func assignTagSuggestions(_ suggestions: [TagSuggestion], to atomIDs: [UUID], isHidden: Bool) {
        guard !suggestions.isEmpty, let firstAtomID = atomIDs.first else { return }
        let limited = isHidden ? suggestions.prefix(5) : suggestions.prefix(1)
        for suggestion in limited {
            guard let type = TagType(rawValue: suggestion.tagType) else { continue }
            if isHidden {
                guard let hiddenTagID = ensureHiddenTag(name: suggestion.name, type: type) else { continue }
                atomIDs.forEach { assignTag(tagID: hiddenTagID, to: $0, isSuggested: true) }
            } else {
                guard let tagID = existingVisibleTagID(named: suggestion.name, type: type) else { continue }
                assignTag(tagID: tagID, to: firstAtomID, isSuggested: true)
            }
        }
    }

    func assignVisibleTagSuggestions(_ suggestions: [TagSuggestion], toFirstAtomOf atomIDs: [UUID]) {
        guard !suggestions.isEmpty, let firstAtomID = atomIDs.first else { return }
        let ranked = suggestions
            .compactMap { suggestion -> (TagSuggestion, UUID)? in
                guard let type = TagType(rawValue: suggestion.tagType),
                      let tagID = existingVisibleTagID(named: suggestion.name, type: type) else {
                    return nil
                }
                return (suggestion, tagID)
            }
            .sorted { lhs, rhs in
                visibleSuggestionRank(for: lhs.0, tagID: lhs.1) > visibleSuggestionRank(for: rhs.0, tagID: rhs.1)
            }

        if let firstSuggestion = ranked.first {
            let tagID = firstSuggestion.1
            assignTag(tagID: tagID, to: firstAtomID, isSuggested: true)
        }
    }

    func assignHiddenTagSuggestions(_ suggestions: [TagSuggestion], toAllAtoms atomIDs: [UUID]) {
        guard !suggestions.isEmpty else { return }
        let ranked = suggestions
            .filter { hiddenSuggestionShouldBeKept($0) }
            .sorted { hiddenSuggestionRank(for: $0) > hiddenSuggestionRank(for: $1) }

        for suggestion in ranked.prefix(5) {
            guard let type = TagType(rawValue: suggestion.tagType) else { continue }
            guard let hiddenTagID = ensureHiddenTag(name: suggestion.name, type: type) else { continue }
            atomIDs.forEach { assignTag(tagID: hiddenTagID, to: $0, isSuggested: true) }
        }
    }

    func updateCaptureStats(captureID: UUID, atomsCount: Int, processingState: CaptureProcessingState, atomizeVersion: String? = nil) {
        let request = NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
        request.predicate = NSPredicate(format: "id == %@", captureID as CVarArg)

        guard let capture = try? context.fetch(request).first else { return }
        capture.atomsCount = Int16(atomsCount)
        capture.processingState = processingState.rawValue
        if let version = atomizeVersion {
            capture.atomizeVersion = version
        }
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
        return TagItem(id: tag.id, name: tag.name, type: type, isCommon: tag.isCommon, isSuggested: false, isUserVisible: tag.isUserVisible)
    }

    private func fetchTagEntity(named name: String, type: TagType) -> TagEntity? {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "name == %@ AND type == %@", name, type.rawValue)
        return try? context.fetch(request).first
    }

    private func fetchTagEntity(by id: UUID) -> TagEntity? {
        let request = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }

    private func existingVisibleTagID(named name: String, type: TagType) -> UUID? {
        guard let tag = fetchTagEntity(named: name, type: type), tag.isUserVisible else { return nil }
        return tag.id
    }

    private func visibleSuggestionRank(for suggestion: TagSuggestion, tagID: UUID) -> Double {
        guard let tag = fetchTagEntity(by: tagID),
              let type = TagType(rawValue: tag.type) else {
            return suggestion.score ?? 0
        }

        let metadata = TagRecommendationMetadata.forTag(name: tag.name, type: type, isUserVisible: true)
        let confirmedCount = confirmedUsageCount(tagID: tagID)

        return (suggestion.score ?? 0) * 100
        + Double(metadata.recommendability.rawValue * 20)
        + Double(metadata.stability.rawValue * 10)
        + Double(metadata.scope.rawValue * 6)
        + min(Double(confirmedCount), 20)
    }

    private func hiddenSuggestionRank(for suggestion: TagSuggestion) -> Double {
        guard let type = TagType(rawValue: suggestion.tagType) else {
            return suggestion.score ?? 0
        }
        let metadata = TagRecommendationMetadata.forTag(name: suggestion.name, type: type, isUserVisible: false)
        return (suggestion.score ?? 0) * 100
        + Double(metadata.recommendability.rawValue * 12)
        + Double(metadata.stability.rawValue * 6)
        + Double(metadata.scope.rawValue * 4)
    }

    private func hiddenSuggestionShouldBeKept(_ suggestion: TagSuggestion) -> Bool {
        guard let type = TagType(rawValue: suggestion.tagType) else { return false }
        let trimmed = suggestion.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.count < 2 { return false }
        if ["事情", "生活", "状态", "问题", "感受", "内容", "记录", "用户"].contains(trimmed) { return false }
        if trimmed.contains("。") || trimmed.contains("，") || trimmed.contains("：") || trimmed.contains("；") { return false }
        return true
    }

    private func confirmedUsageCount(tagID: UUID) -> Int {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "tagID == %@ AND isSuggested == NO", tagID as CVarArg)
        return (try? context.count(for: request)) ?? 0
    }

    private func hasTag(tagID: UUID, atomID: UUID) -> Bool {
        let request = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        request.predicate = NSPredicate(format: "atomID == %@ AND tagID == %@", atomID as CVarArg, tagID as CVarArg)
        return (try? context.count(for: request)) ?? 0 > 0
    }

    private func clearAtoms(captureID: UUID) {
        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        request.predicate = NSPredicate(format: "captureID == %@", captureID as CVarArg)
        guard let atoms = try? context.fetch(request), !atoms.isEmpty else { return }
        let atomIDs = atoms.map { $0.id }
        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID IN %@", atomIDs)
        if let links = try? context.fetch(linkRequest) {
            links.forEach { context.delete($0) }
        }
        atoms.forEach { context.delete($0) }
    }

    private func ensureHiddenTag(name: String, type: TagType) -> UUID? {
        if let existing = fetchTagEntity(named: name, type: type) {
            return existing.isUserVisible ? nil : existing.id
        }
        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = name
        tag.type = type.rawValue
        tag.isUserVisible = false
        tag.isCommon = false
        tag.createdAt = Date()
        saveContext()
        return tag.id
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
