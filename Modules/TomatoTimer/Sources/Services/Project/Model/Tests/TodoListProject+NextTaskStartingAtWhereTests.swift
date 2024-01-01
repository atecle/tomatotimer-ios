import XCTest
@testable import TomatoTimer

final class TodoListProject_NextTaskStartingAtWhereTests: XCTestCase {

    func test_finds_next_task() {
        var sut = (0...5).map { _ in TodoListTask() }
        sut[4].completed = true
        let result = sut.next(startingAt: sut[0], where: { $0.completed == true })
        XCTAssertEqual(result, sut[4])
    }

    func test_returns_nil_if_not_found() {
        let sut = (0...5).map { _ in TodoListTask() }
        let result = sut.next(startingAt: sut[0], where: { $0.completed == true })
        XCTAssertNil(result)
    }

    func test_empty_array_returns_nil() {
        let sut = [TodoListTask]()
        let task = TodoListTask()
        let result = sut.next(startingAt: task, where: { $0.completed == true })
        XCTAssertNil(result)
    }

}
