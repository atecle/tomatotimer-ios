import XCTest

@testable import TomatoTimer

final class FocusListTaskEntityTests: EntityTestCase {

    override func test_update() {
        let task = FocusListTask(title: "Title", completed: true, inProgress: true, order: 3)
        let entity = FocusListTaskEntity(context: context)
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
            Int(entity.order),
            task.order
        )
        XCTAssertEqual(
            entity.completed,
            task.completed
        )
        XCTAssertEqual(
            entity.inProgress,
            task.inProgress
        )
    }

    override func test_toNonManagedObject() {
        let task = FocusListTask(title: "Title", completed: true, inProgress: true, order: 3)
        let entity = FocusListTaskEntity(context: context)

        entity.update(from: task, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), task)
    }
}
