import XCTest
import ComposableArchitecture

@testable import TomatoTimer

@MainActor
final class PlannerHomeReducerTests: XCTestCase {

    func test_deleting_task_should_remove_task_from_project() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(),
            TodoListTask()
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        await store.send(.delete(at: IndexSet(integer: 0))) { state in
            state.project.tasks.remove(at: 0)
        }
    }

    func test_setting_task_in_progress_should_set_correct_task_in_progress() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(),
            TodoListTask()
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        await store.send(.setInProgressTask(project.tasks[0].toListItem)) { state in
            state.project.tasks[0].inProgress = true
        }
    }

    func test_adding_task_should_append_task_to_project_task_list() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(),
            TodoListTask()
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        let uuid = UUID()
        let date = Date()
        store.dependencies.uuid = UUIDGenerator({
            return uuid
        })
        store.dependencies.date = DateGenerator({
            return date
        })
        let taskTitle = "New Task"
        await store.send(.addTask(taskTitle, at: nil)) { state in
            state.project.tasks.append(TodoListTask(id: uuid, title: taskTitle, creationDate: date))
        }
    }

    func test_toggling_task_completed_should_update_task_completed() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(),
            TodoListTask()
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        let uuid = UUID()
        let date = Date()
        store.dependencies.uuid = .constant(uuid)

        store.dependencies.date = .constant(date)
        var edited = store.state.project.tasks[0]
        edited.completed.toggle()
        await store.send(.editTask(edited.toListItem)) { state in
            state.project.tasks[0] = project.tasks[1]
            state.project.tasks[1] = project.tasks[0]
            state.project.tasks[1].completed = true
        }
        edited.completed.toggle()
        await store.send(.editTask(edited.toListItem)) { state in
            state.project.tasks[1].completed = false
        }
    }

    func test_toggling_in_progress_task_completed_moves_to_bottom() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(inProgress: true),
            TodoListTask()
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        let uuid = UUID()
        let date = Date()
        store.dependencies.uuid = .constant(uuid)
        store.dependencies.date = .constant(date)

        var edited = store.state.project.tasks[0]
        edited.completed.toggle()
        await store.send(.editTask(edited.toListItem)) { state in
            state.project.tasks[0] = project.tasks[1]
            state.project.tasks[1] = project.tasks[0]

            state.project.tasks[0].inProgress = true
            state.project.tasks[1].completed = true
            state.project.tasks[1].inProgress = false

        }
    }

    func test_toggling__in_progress_task_completed_in_project_with_one_task_leaves_none_in_progress() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(inProgress: true)
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        let uuid = UUID()
        let date = Date()
        store.dependencies.uuid = .constant(uuid)
        store.dependencies.date = .constant(date)

        var edited = store.state.project.tasks[0]
        edited.completed.toggle()
        await store.send(.editTask(edited.toListItem)) { state in
            state.project.tasks[0].inProgress = false
            state.project.tasks[0].completed = true
        }
    }

    func test_toggling_in_progress_task_completed_when_it_is_last_task_makes_first_task_in_progress() async {
        let mockServices = MockServices()
        let project = TodoListProject(tasks: [
            TodoListTask(),
            TodoListTask(inProgress: true)
        ])

        let store = TestStore(
            initialState: PlannerHomeReducer.State(
                project: project,
                allProjects: [project]
            ),
            reducer: PlannerHomeReducer()
        )

        store.dependencies.services = mockServices
        let uuid = UUID()
        let date = Date()
        store.dependencies.uuid = .constant(uuid)
        store.dependencies.date = .constant(date)

        var edited = store.state.project.tasks[1]
        edited.completed.toggle()
        await store.send(.editTask(edited.toListItem)) { state in
            state.project.tasks[0].inProgress = true
            state.project.tasks[1].inProgress = false
            state.project.tasks[1].completed = true

        }
    }
}

extension TodoListTask {

    var toListItem: PlannerHomeReducer.PlannerListItem {
        return .task(.init(id: id, title: title, completed: completed, inProgress: inProgress))
    }
}
