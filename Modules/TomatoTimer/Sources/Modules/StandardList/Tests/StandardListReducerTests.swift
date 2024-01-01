//import XCTest
//import ComposableArchitecture
//
//@testable import TomatoTimer
//
//@MainActor
//final class StandardListReducerTests: XCTestCase {
//
//    func test_add_task_should_append_task_and_save() async {
//        let uuid = UUID()
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid)
//            ),
//            reducer: StandardListReducer()
//        )
//
//        sut.dependencies.uuid = .constant(uuid)
//        let task = FocusListTask(id: uuid, title: "Title", inProgress: true)
//        await sut.send(.addTask(task)) {
//            $0.list.tasks = [task]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_add_task_empty_state_should_do_nothing() async {
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init()
//            ),
//            reducer: StandardListReducer()
//        )
//
//        await sut.send(.addTaskEmptyStatePressed)
//    }
//
//    func test_on_commit_empty_state_should_add_in_progress_task() async {
//        let uuid = UUID()
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [])
//            ),
//            reducer: StandardListReducer()
//        )
//        sut.dependencies.uuid = .constant(uuid)
//        let task = FocusListTask(id: uuid, title: "Title", inProgress: true)
//        await sut.send(.onCommitAddTaskEmptyState("Title")) {
//            $0.list.tasks = [task]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_update_title_should_update_title_and_save() async {
//        let uuid = UUID()
//        let task = FocusListTask(id: uuid, title: "Title", inProgress: true)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        sut.dependencies.uuid = .constant(uuid)
//        var updated = task
//        updated.title = "Updated"
//        await sut.send(.updateTitle(for: task, title: "Updated")) {
//            $0.list.tasks = [updated]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggle_completed_should_mark_next_task_in_progress() async {
//        let uuid = UUID()
//        var task1 = FocusListTask(id: uuid, title: "Title", inProgress: true)
//        var task2 = FocusListTask(id: uuid, title: "Title", inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        task1.completed = true
//        task1.inProgress = false
//        task2.inProgress = true
//        await sut.send(.toggleCompleted(task1)) {
//            $0.list.tasks = [task1, task2]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggle_completed_should_mark_task_in_progress_if_only_incomplete_task() async {
//        let uuid = UUID()
//        let task = FocusListTask(id: uuid, title: "Title", completed: true, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        var updated = task
//        updated.inProgress = true
//        updated.completed = false
//        await sut.send(.toggleCompleted(task)) {
//            $0.list.tasks = [updated]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_complete_current_task_should_toggle_current_task_completed() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        var updated1 = task1
//        updated1.inProgress = false
//        updated1.completed = true
//
//        var updated2 = task2
//        updated2.inProgress = true
//        await sut.send(.toggleCompleted(task1)) {
//            $0.list.tasks = [updated1, updated2]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_list_row_menu_shouldnt_allow_completed_tasks_to_be_marked_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: true, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        await sut.send(.listRowMenuButtonPressed(task2)) {
//            $0.confirmationDialog = .init(
//                title: TextState("What do you want to do?"),
//                buttons: [
//                    ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task2))) { TextState("Delete") }
//                ]
//            )
//        }
//    }
//
//    func test_list_row_menu_shouldnt_allow_in_progress_tasks_to_be_marked_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: true, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        await sut.send(.listRowMenuButtonPressed(task1)) {
//            $0.confirmationDialog = .init(
//                title: TextState("What do you want to do?"),
//                buttons: [
//                    ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task1))) { TextState("Delete") }
//                ]
//            )
//        }
//    }
//
//    func test_deleting_in_progress_task_should_mark_next_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        await sut.send(.listRowMenuButtonPressed(task1)) {
//            $0.confirmationDialog = .init(
//                title: TextState("What do you want to do?"),
//                buttons: [
//                    ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task1))) { TextState("Delete") }
//                ]
//            )
//        }
//
//        await sut.send(.confirmationDialog(.presented(.confirmDeleteTask(task1)))) {
//            $0.confirmationDialog = nil
//            $0.alert = .init(
//                title: TextState("Are you sure you want to delete this task?"), buttons: [
//                    ButtonState(role: .destructive, action: .delete(task1)) {
//                        TextState("Delete")
//                    }
//                ]
//            )
//        }
//
//        var updatedTask2 = task2
//        updatedTask2.inProgress = true
//        await sut.send(.alert(.presented(.delete(task1)))) {
//            $0.list.tasks = [updatedTask2]
//            $0.alert = nil
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggle_task_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: false)
//        let sut = TestStoreOf<StandardListReducer>(
//            initialState: StandardListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: StandardListReducer()
//        )
//
//        await sut.send(.listRowMenuButtonPressed(task2)) {
//            $0.confirmationDialog = .init(
//                title: TextState("What do you want to do?"),
//                buttons: [
//                    ButtonState(action: .send(.toggleInProgress(task2))) { TextState("Mark In Progress") },
//                    ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task2))) { TextState("Delete") }
//                ]
//            )
//        }
//
//        var updatedTask2 = task2
//        updatedTask2.inProgress = true
//        await sut.send(.confirmationDialog(.presented(.toggleInProgress(task2)))) {
//            $0.confirmationDialog = nil
//            $0.list.tasks = [task1, updatedTask2]
//        }
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//}
