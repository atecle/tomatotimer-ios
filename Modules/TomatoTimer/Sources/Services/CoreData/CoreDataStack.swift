import Foundation
import CoreData
import Combine
import XCTestDynamicOverlay
import CloudKit

protocol CoreDataStackType {

    var container: NSPersistentContainer { get set }
    var backgroundContext: NSManagedObjectContext { get }
    var viewContext: NSManagedObjectContext { get }

    func performChanges(changes: @escaping (NSManagedObjectContext) throws -> Void) async throws

    func fetch<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping ([T]) throws -> Void
    ) async throws

    func fetchOne<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping (T?) throws -> Void
    ) async throws

    func update<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping ([T]) throws -> Void
    ) async throws

    func updateRelationship<T: ManagedObject, S: ManagedObject>(
        updateRequest: NSFetchRequest<T>,
        fetchRequest: NSFetchRequest<S>,
        _ completion: @escaping ([T], [S]) throws -> Void
    ) async throws

    func updateOne<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping (T?, NSManagedObjectContext) throws -> Void
    ) async throws

    func monitor<T: ManagedObject>(_ request: NSFetchRequest<T>) -> AnyPublisher<[T.NonManaged], Error>

    func delete<T: ManagedObject>(_ request: NSFetchRequest<T>) async throws

    func deleteOne<T: ManagedObject>(_ request: NSFetchRequest<T>) async throws

    func clearDatabase() async throws
}

struct CoreDataStack: CoreDataStackType {

    var container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext

    @discardableResult
    static func createStack(
        container: NSPersistentContainer
    ) -> CoreDataStackType {
        live = CoreDataStack(container)
        return live
    }

    static var live: CoreDataStackType!

    init(
        _ container: NSPersistentContainer
    ) {
        self.container = container
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.viewContext = container.viewContext
        self.backgroundContext = container.newBackgroundContext()
        self.backgroundContext.automaticallyMergesChangesFromParent = true

    }

    func monitor<T: ManagedObject>(_ request: NSFetchRequest<T>) -> AnyPublisher<[T.NonManaged], Error> {
        return viewContext.changesPublisher(for: request)
            .scan([]) { (accum: [T.NonManaged], diff: CollectionDifference<T.NonManaged>) -> [T.NonManaged] in
                return accum.applying(diff) ?? []
            }
            .eraseToAnyPublisher()
    }

    func fetch<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping ([T]) throws -> Void
    ) async throws {
        try await backgroundContext.perform {
            try completion(try self.fetch(request))
        }
    }

    func fetchOne<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping (T?) throws -> Void
    ) async throws {
        request.fetchLimit = 1
        try await backgroundContext.perform {
            try completion(try self.fetch(request).first)
        }
    }

    func update<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping ([T]) throws -> Void
    ) async throws {
        try await fetch(request) { entities in
            try completion(entities)
        }
    }

    func updateOne<T: ManagedObject>(
        _ request: NSFetchRequest<T>,
        _ completion: @escaping (T?, NSManagedObjectContext) throws -> Void
    ) async throws {
        try await fetchOne(request) { entity in
            try completion(entity, self.backgroundContext)
            try backgroundContext.saveIfNeeded()
        }
    }

    func updateRelationship<T: ManagedObject, S: ManagedObject>(
        updateRequest: NSFetchRequest<T>,
        fetchRequest: NSFetchRequest<S>,
        _ completion: @escaping ([T], [S]) throws -> Void
    ) async throws {
        try await fetch(updateRequest) { entities in
            let fetchedEntities = try self.fetch(fetchRequest)
            try completion(entities, fetchedEntities)
            try backgroundContext.saveIfNeeded()
        }
    }

    func delete<T: ManagedObject>(_ request: NSFetchRequest<T>) async throws {
        try await performChanges { context in
            let results = try context.fetch(request)
            for result in results {
                context.delete(result)
            }
        }
    }

    func deleteOne<T: ManagedObject>(_ request: NSFetchRequest<T>) async throws {
        request.fetchLimit = 1
        try await performChanges { context in
            let results = try context.fetch(request)
            guard let result = results.first else { return }
            context.delete(result)
        }
    }

    func performChanges(changes: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await backgroundContext.performChanges {
            try changes(backgroundContext)
            try backgroundContext.saveIfNeeded()
        }
    }

    func clearDatabase() async throws {
        let projectEntity = FocusProjectEntity.fetchRequest()
        let activityGoalEntity = ActivityGoalEntity.fetchRequest()
        let recurrenceEntity = FocusProjectRecurrenceEntity.fetchRequest()
        let settingsEntity = SettingsEntity.fetchRequest()
        let todoListProjectEntity = ToDoListProjectEntity.fetchRequest()
        let userEntity = UserEntity.fetchRequest()
        let tomatoTimerEntity = TomatoTimerEntity.fetchRequest()

        try await delete(projectEntity)
        try await delete(activityGoalEntity)
        try await delete(recurrenceEntity)
        try await delete(settingsEntity)
        try await delete(todoListProjectEntity)
        try await delete(userEntity)
        try await delete(tomatoTimerEntity)

        try await deleteICloud()
    }

    private func deleteICloud() async throws {
        let container = CKContainer(identifier: "iCloud.com.adamtecle.tomatotimer")

        let database = container.privateCloudDatabase

        // instruct iCloud to delete the whole zone (and all of its records)
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            database.delete(withRecordZoneID: .init(zoneName: "com.apple.coredata.cloudkit.zone"), completionHandler: { (_, error) -> Void in
                NSUbiquitousKeyValueStore.default.removeObject(forKey: "icloud_sync")
                if let error = error {
                    print("deleting zone error \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(with: .success(()))
                }
            })
        }
    }
    private func fetch<T: ManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        return try backgroundContext.fetch(request)
    }

}

extension NSManagedObjectContext {

    /// Only performs a save if there are changes to commit.
    /// - Returns: `true` if a save was needed. Otherwise, `false`.
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}

extension NSPersistentContainer {
    static func makePersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentCloudKitContainer(name: "Model")
        // Disable CloudKit syncing by default
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if !NSUbiquitousKeyValueStore.default.bool(forKey: "icloud_sync") {
            description.cloudKitContainerOptions = nil
        }
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }
}
