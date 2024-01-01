import XCTest

@testable import TomatoTimer

final class ToDoListTaskEntityTests: EntityTestCase {

    override func test_update() {
        let task = TodoListTask(title: "Test")
        let entity = ToDoListTaskEntity(context: context)

        entity.update(from: task, context: context)
        XCTAssertEqual(
            entity.id,
            task.id
        )
        XCTAssertEqual(
            entity.title,
            task.title
        )
        XCTAssertEqual(
            entity.id,
            task.id
        )
        XCTAssertEqual(
            entity.order,
            Int64(task.order)
        )
        XCTAssertEqual(
            entity.inProgress,
            task.inProgress
        )
        XCTAssertEqual(
            entity.completed,
            task.completed
        )
        XCTAssertEqual(
            entity.creationDate,
            task.creationDate
        )
        XCTAssertEqual(
            entity.creationDate,
            task.creationDate
        )
        XCTAssertNil(entity.project)
    }

    override func test_toNonManagedObject() {
        let task = TodoListTask(title: "Test")
        let entity = ToDoListTaskEntity(context: context)

        entity.update(from: task, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), task)
    }
}
