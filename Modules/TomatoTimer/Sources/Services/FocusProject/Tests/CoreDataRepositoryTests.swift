import XCTest
import CustomDump
import CoreData

@testable import TomatoTimer
final class CoreDataRepositoryTests: CoreDataTestCase<NSPersistentContainer> {

    func test_create() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let project = FocusProject()
        try await sut.create(project)

        var toNonManagedObject: FocusProject!
        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssert(results.count == 1)
            toNonManagedObject = FocusProject(entity: results[0])!
        }

        XCTAssertNoDifference(project, toNonManagedObject)
    }

    func test_fetch() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let project = FocusProject()
        try await sut.create(project)

        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.fetch(request) { results in
            let nonManaged = results.compactMap { $0.toNonManagedObject() }
            XCTAssertNoDifference([project], nonManaged)
        }
    }

    func test_fetchOne() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let project = FocusProject()
        try await sut.create(project)

        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.fetchOne(request) { result in
            XCTAssertNoDifference(project, result?.toNonManagedObject())
        }
    }

    func test_delete() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        try await sut.create(FocusProject())
        try await sut.create(FocusProject())
        try await sut.create(FocusProject())

        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.delete(request)
        try await sut.fetch(request) { results in
            XCTAssertTrue(results.count == 0)
        }
    }

    func test_deleteOne() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let toDelete = FocusProject()
        let proj2 = FocusProject()
        let proj3 = FocusProject()
        try await sut.create(toDelete)
        try await sut.create(proj2)
        try await sut.create(proj3)

        let deleteRequest = FocusProjectEntity.fetchRequest()
        deleteRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        deleteRequest.predicate = .byID(toDelete.id)
        try await sut.deleteOne(deleteRequest)

        let fetchRequest = FocusProjectEntity.fetchRequest()
        fetchRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.fetch(fetchRequest) { results in
            XCTAssertTrue(results.count == 2)
            XCTAssertTrue(results.contains(where: { $0.id == proj2.id }))
            XCTAssertTrue(results.contains(where: { $0.id == proj3.id }))
        }
    }

    func test_update() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let proj1 = FocusProject()
        let proj2 = FocusProject()
        let proj3 = FocusProject()
        try await sut.create(proj1)
        try await sut.create(proj2)
        try await sut.create(proj3)

        let updateRequest = FocusProjectEntity.fetchRequest()
        updateRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.update(updateRequest) { entities in
            for entity in entities {
                entity.title = "Renamed"
            }
        }

        let fetchRequest = FocusProjectEntity.fetchRequest()
        fetchRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.fetch(fetchRequest) { results in
            XCTAssertTrue(results.count == 3)
            for result in results {
                XCTAssertEqual(result.title, "Renamed")
            }
        }
    }

    func test_updateOne() async throws {
        let sut = CoreDataRepository<FocusProjectEntity>.live(
            coreDataStack: CoreDataStack.live
        )
        let proj1 = FocusProject()
        let proj2 = FocusProject(title: "Not renamed")
        let proj3 = FocusProject(title: "Not renamed")
        try await sut.create(proj1)
        try await sut.create(proj2)
        try await sut.create(proj3)

        let updateRequest = FocusProjectEntity.fetchRequest()
        updateRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        updateRequest.predicate = .byID(proj1.id)
        try await sut.updateOne(updateRequest) { entity, _ in
            entity?.title = "Renamed"
        }

        let fetchRequest = FocusProjectEntity.fetchRequest()
        fetchRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        try await sut.fetch(fetchRequest) { results in
            XCTAssertTrue(results.count == 3)
            for result in results where result.id == proj1.id {
                XCTAssertEqual(result.title, "Renamed")
            }

            for result in results where result.id != proj1.id {
                XCTAssertEqual(result.title, "Not renamed")
            }
        }
    }
}
