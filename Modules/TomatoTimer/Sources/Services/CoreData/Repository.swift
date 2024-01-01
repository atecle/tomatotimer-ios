import Foundation
import Combine
import CoreData

protocol RepositoryType {
    associatedtype Entity: ManagedObject

    func fetchAll(
        _ fetchRequest: NSFetchRequest<Entity>
    ) async throws -> [Entity.NonManaged]

    func monitor(
        _ fetchRequest: NSFetchRequest<Entity>
    ) -> AnyPublisher<[Entity.NonManaged], Error>

    func create(_ nonManaged: Entity.NonManaged) async throws

    func update(
        fetchRequest: NSFetchRequest<Entity>,
        nonManaged: Entity.NonManaged
    ) async throws

    func delete(
        fetchRequest: NSFetchRequest<Entity>,
        nonManaged: Entity.NonManaged
    ) async throws
}

struct Repository<Entity: ManagedObject>: RepositoryType {

    private let coreDataStack: CoreDataStackType

    init(coreDataStack: CoreDataStackType) {
        self.coreDataStack = coreDataStack
    }

    func fetchAll(
        _ fetchRequest: NSFetchRequest<Entity>
    ) async throws -> [Entity.NonManaged] {
        try await coreDataStack.viewContext.perform {
            let results: [Entity] = try coreDataStack.viewContext.fetch(fetchRequest)
            return results.compactMap { $0.toNonManagedObject() }
        }
    }

    func monitor(_ fetchRequest: NSFetchRequest<Entity>) -> AnyPublisher<[Entity.NonManaged], Error> {
        coreDataStack
            .viewContext.changesPublisher(for: fetchRequest)
            .scan([]) { (accum: [Entity.NonManaged], diff: CollectionDifference<Entity.NonManaged>) -> [Entity.NonManaged] in
                return accum.applying(diff) ?? []
            }
            .eraseToAnyPublisher()
    }

    func create(_ nonManaged: Entity.NonManaged) async throws {
        try await coreDataStack.viewContext.performChanges {
            let entity: Entity = coreDataStack.viewContext.insertObject()
            entity.update(from: nonManaged, context: coreDataStack.viewContext)
            try coreDataStack.viewContext.save()
        }
    }

    func update(
        fetchRequest: NSFetchRequest<Entity>,
        nonManaged: Entity.NonManaged
    ) async throws {
        try await coreDataStack.viewContext.performChanges {
            let results = try coreDataStack.viewContext.fetch(fetchRequest)

            if results.isEmpty {
                let entity: Entity = coreDataStack.viewContext.insertObject()
                entity.update(from: nonManaged, context: coreDataStack.viewContext)
            }

            for result in results {
                result.update(from: nonManaged, context: coreDataStack.viewContext)
            }

            try coreDataStack.viewContext.save()
        }
    }

    func delete(
        fetchRequest: NSFetchRequest<Entity>,
        nonManaged: Entity.NonManaged
    ) async throws {
        try await coreDataStack.viewContext.performChanges {
            let results = try coreDataStack.viewContext.fetch(fetchRequest)

            for result in results {
                coreDataStack.viewContext.delete(result)
            }

            try coreDataStack.viewContext.save()
        }
    }
}
