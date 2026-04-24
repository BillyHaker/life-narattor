import CoreData
import Foundation
import Testing
@testable import Life_Narattor

struct AtomTagStoreTests {
    @Test("markAsKey persists to store")
    func markAsKeyPersists() throws {
        let context = makeContext()
        let atomID = try seedAtom(in: context)
        let store = AtomTagStore(context: context)

        store.markAsKey(atomID: atomID)

        let request = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        request.predicate = NSPredicate(format: "id == %@", atomID as CVarArg)
        let atom = try #require(context.fetch(request).first)
        #expect(atom.isKey == true)
    }

    @Test("deleteAtom removes atom and associated links")
    func deleteAtomRemovesAtomAndLinks() throws {
        let context = makeContext()
        let atomID = try seedAtom(in: context)
        let tagID = try seedTag(in: context)
        try seedAtomTagLink(atomID: atomID, tagID: tagID, in: context)
        let store = AtomTagStore(context: context)

        store.deleteAtom(atomID: atomID)

        let atomRequest = NSFetchRequest<AtomEntity>(entityName: "AtomEntity")
        atomRequest.predicate = NSPredicate(format: "id == %@", atomID as CVarArg)
        let linkRequest = NSFetchRequest<AtomTagEntity>(entityName: "AtomTagEntity")
        linkRequest.predicate = NSPredicate(format: "atomID == %@", atomID as CVarArg)

        #expect(try context.count(for: atomRequest) == 0)
        #expect(try context.count(for: linkRequest) == 0)
    }
}

private extension AtomTagStoreTests {
    func makeContext() -> NSManagedObjectContext {
        PersistenceController(inMemory: true).container.viewContext
    }

    func seedAtom(in context: NSManagedObjectContext) throws -> UUID {
        let atom = AtomEntity(context: context)
        let id = UUID()
        atom.id = id
        atom.captureID = UUID()
        atom.type = AtomType.event.rawValue
        atom.content = "测试 atom"
        atom.orderInCapture = 0
        atom.isKey = false
        atom.createdAt = Date()
        atom.startChar = -1
        atom.endChar = -1
        atom.atomizeVersion = "test_v1"
        try context.save()
        return id
    }

    func seedTag(in context: NSManagedObjectContext) throws -> UUID {
        let tag = TagEntity(context: context)
        let id = UUID()
        tag.id = id
        tag.name = "测试标签"
        tag.type = TagType.project.rawValue
        tag.isUserVisible = true
        tag.isCommon = false
        tag.createdAt = Date()
        try context.save()
        return id
    }

    func seedAtomTagLink(atomID: UUID, tagID: UUID, in context: NSManagedObjectContext) throws {
        let link = AtomTagEntity(context: context)
        link.id = UUID()
        link.atomID = atomID
        link.tagID = tagID
        link.createdAt = Date()
        link.isSuggested = false
        try context.save()
    }
}
