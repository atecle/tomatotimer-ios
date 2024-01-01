import Foundation
import CoreData
import Combine
import ComposableArchitecture

struct CoreDataRepository<T: ManagedObject> {

    // MARK: Create

    var create: (T.NonManaged) async throws -> Void

    // MARK: Read

    var monitor: (NSFetchRequest<T>) -> AnyPublisher<[T.NonManaged], Error>
    var fetchNonManaged: (NSFetchRequest<T>) async throws -> [T.NonManaged]
    var fetch: (NSFetchRequest<T>, @escaping ([T]) -> Void) async throws -> Void
    var fetchOne: (NSFetchRequest<T>, @escaping (T?) -> Void) async throws -> Void

    // MARK: Update

    var update: (NSFetchRequest<T>, @escaping ([T]) -> Void) async throws -> Void
    var updateOne: (NSFetchRequest<T>, @escaping (T?, NSManagedObjectContext) -> Void) async throws -> Void

    // MARK: Delete

    var delete: (NSFetchRequest<T>) async throws -> Void
    var deleteOne: (NSFetchRequest<T>) async throws -> Void

    static func live(
        coreDataStack: CoreDataStackType
    ) -> Self {
        Self(
            create: { nonManagedObject in
                try await coreDataStack.performChanges { context in
                    let entity: T = context.insertObject()
                    entity.update(from: nonManagedObject, context: context)
                }
            },
            monitor: { request in
                return coreDataStack.monitor(request)
            },
            fetchNonManaged: { request in
                try await coreDataStack.backgroundContext.perform {
                    let results: [T] = try coreDataStack.backgroundContext.fetch(request)
                    return results.compactMap { $0.toNonManagedObject() }
                }
            },
            fetch: { request, completion in
                try await coreDataStack.fetch(request, completion)
            },
            fetchOne: { request, completion in
                try await coreDataStack.fetchOne(request, completion)
            },
            update: { request, updateEntities in
                try await coreDataStack.update(request, updateEntities)
            },
            updateOne: { request, updateEntity in
                try await coreDataStack.updateOne(request, updateEntity)
            },
            delete: { request in
                try await coreDataStack.delete(request)
            },
            deleteOne: { request in
                try await coreDataStack.deleteOne(request)
            }
        )
    }
}
