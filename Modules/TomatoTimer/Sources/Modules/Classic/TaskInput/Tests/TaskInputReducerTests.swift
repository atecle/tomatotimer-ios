import XCTest
import ComposableArchitecture
import UIColorHexSwift
@testable import TomatoTimer

private let uuid = UUID(uuidString: "03458a8b-8c55-4576-9b4f-758b86e31d8e")!

@MainActor
final class TaskInputReducerTests: XCTestCase {

    var settings: Settings!
    var project: TodoListProject!

    override func setUp() async throws {
        settings = Settings()
        project = .init()
    }

    func test_setting_task_creates_project_with_one_in_progress_task() async {
        let store = TestStore(
            initialState: TaskInputReducer.State(settings: settings, project: project),
            reducer: TaskInputReducer()
        )

        let mockServices = MockServices()
        let now = Date()
        store.dependencies.uuid = .constant(uuid)
        store.dependencies.date = DateGenerator({
            return now
        })
        store.dependencies.services = mockServices
        let taskTitle = "Some task"
        await store.send(.setTask(taskTitle)) { state in
            var task = TodoListTask(id: uuid, creationDate: now)
            task.inProgress = true
            task.title = taskTitle
            state.project.tasks = [task]
        }
    }

    func test_empty_task_deletes_tasks() async {
        project.tasks = [.init()]
        let store = TestStore(
            initialState: TaskInputReducer.State(settings: settings, project: project),
            reducer: TaskInputReducer()
        )

        let mockServices = MockServices()
        let now = Date()
        store.dependencies.uuid = .constant(uuid)
        store.dependencies.date = DateGenerator({
            return now
        })
        store.dependencies.services = mockServices
        await store.send(.setTask("")) { state in
            state.project.tasks = []
        }
    }
}
