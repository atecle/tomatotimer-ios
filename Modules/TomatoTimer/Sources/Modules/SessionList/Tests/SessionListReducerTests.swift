//import XCTest
//import ComposableArchitecture
//
//@testable import TomatoTimer
//
//@MainActor
//final class SessionListReducerTests: XCTestCase {
//
//    func test_add_task_appends_to_tasks_and_saves() async {
//        let uuid = UUID()
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        let task = FocusListTask(id: uuid)
//        await sut.send(.addTask(task)) {
//            $0.list.tasks.append(task)
//        }
//
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggle_in_progress_task_completed_should_mark_next_task_in_progress_and_complete_session() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: UUID(), title: "Task1", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: UUID(), title: "Task2", completed: false, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updatedTask1 = task1
//        updatedTask1.completed = true
//        updatedTask1.inProgress = false
//        var updatedTask2 = task2
//        updatedTask2.inProgress = true
//
//        await sut.send(.toggleCompleted(task1)) {
//            $0.list.tasks = [updatedTask1, updatedTask2]
//        }
//
//        await sut.receive(.delegate(.completeSession))
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggling_task_incomplete_when_it_is_only_task_should_mark_in_progress() async {
//        let uuid = UUID()
//        let task = FocusListTask(id: UUID(), title: "Task1", completed: true, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updatedTask = task
//        updatedTask.completed = false
//        updatedTask.inProgress = true
//        await sut.send(.toggleCompleted(task)) {
//            $0.list.tasks = [updatedTask]
//        }
//
//        await sut.receive(.delegate(.setActiveSession(0)))
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggling_task_complete_when_it_is_only_task_should_mark_in_progress() async {
//        let uuid = UUID()
//        let task = FocusListTask(id: UUID(), title: "Task1", completed: true, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updatedTask = task
//        updatedTask.completed = false
//        updatedTask.inProgress = true
//        await sut.send(.toggleCompleted(task)) {
//            $0.list.tasks = [updatedTask]
//        }
//
//        await sut.receive(.delegate(.setActiveSession(0)))
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggling_task_complete_when_before_in_progress_task() async {
//        let task1 = FocusListTask(id: UUID(), title: "Task1", completed: true, inProgress: false)
//        let task2 = FocusListTask(id: UUID(), title: "Task2", completed: true, inProgress: false)
//        let task3 = FocusListTask(id: UUID(), title: "Task3", completed: false, inProgress: true)
//        let task4 = FocusListTask(id: UUID(), title: "Task4", completed: false, inProgress: false)
//        let uuid = UUID()
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2, task3, task4])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updatedTasks = [task1, task2, task3, task4]
//        updatedTasks[0].completed = false
//        updatedTasks[0].inProgress = true
//        updatedTasks[1].completed = false
//        updatedTasks[2].inProgress = false
//        await sut.send(.toggleCompleted(task1)) {
//            $0.alert = .init(
//                title: TextState("Mark Task1 incomplete?"),
//                message: TextState("This will mark the task in progress and mark all subsequent tasks and timer sessions incomplete."),
//                buttons: [
//                    ButtonState(action: .toggleCompleted(task1)) {
//                        TextState("Confirm")
//                    },
//                    ButtonState(role: .cancel, label: {
//                        TextState("Cancel")
//                    })
//                ]
//            )
//        }
//
//        await sut.send(.alert(.presented(.toggleCompleted(task1)))) {
//            $0.alert = nil
//            $0.list.tasks = updatedTasks
//        }
//
//        await sut.receive(.delegate(.setActiveSession(0)))
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_toggling_task_complete_when_after_in_progress_task() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: UUID(), title: "Task1", completed: true, inProgress: false)
//        let task2 = FocusListTask(id: UUID(), title: "Task2", completed: false, inProgress: true)
//        let task3 = FocusListTask(id: UUID(), title: "Task3", completed: false, inProgress: false)
//        let task4 = FocusListTask(id: UUID(), title: "Task4", completed: false, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2, task3, task4])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updatedTasks = [task1, task2, task3, task4]
//        updatedTasks[0].completed = true
//        updatedTasks[1].completed = true
//        updatedTasks[1].inProgress = false
//        updatedTasks[2].completed = true
//        updatedTasks[2].inProgress = false
//        updatedTasks[3].completed = false
//        updatedTasks[3].inProgress = true
//
//        await sut.send(.toggleCompleted(task3)) {
//            $0.alert = .init(
//                title: TextState("Mark Task3 completed?"),
//                message: TextState("This will also set previous tasks and timer sessions complete."),
//                buttons: [
//                    ButtonState(action: .toggleCompleted(task3)) {
//                        TextState("Confirm")
//                    },
//                    ButtonState(role: .cancel, label: {
//                        TextState("Cancel")
//                    })
//                ]
//            )
//        }
//
//        await sut.send(.alert(.presented(.toggleCompleted(task3)))) {
//            $0.alert = nil
//            $0.list.tasks = updatedTasks
//        }
//
//        await sut.receive(.delegate(.setActiveSession(3)))
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_update_title() async {
//        let task1 = FocusListTask(id: UUID(), title: "Task1", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: UUID(), title: "Task2", completed: false, inProgress: false)
//        let uuid = UUID()
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        var updated = [task1, task2]
//        updated[0].title = "Updated"
//
//        await sut.send(.updateTitle(for: task1, title: "Updated")) {
//            $0.list.tasks = updated
//        }
//
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//
//    func test_list_row_menu_shouldnt_allow_completed_tasks_to_be_marked_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: uuid, title: "Title", completed: true, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: SessionListReducer()
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
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: SessionListReducer()
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
//    func test_confirmation_dialog_mark_in_progress() async {
//        let uuid = UUID()
//        let task1 = FocusListTask(id: UUID(), title: "Task1", completed: false, inProgress: true)
//        let task2 = FocusListTask(id: UUID(), title: "Task2", completed: false, inProgress: false)
//        let sut = TestStoreOf<SessionListReducer>(
//            initialState: SessionListReducer.State(
//                list: .init(id: uuid, tasks: [task1, task2])
//            ),
//            reducer: SessionListReducer()
//        )
//
//        await sut.send(.listRowMenuButtonPressed(task2)) {
//            $0.confirmationDialog = .init(
//                title: TextState("What do you want to do?"),
//                buttons: [
//                    ButtonState(action: .send(.confirmMarkInProgress(task2))) { TextState("Mark In Progress") },
//                    ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task2))) { TextState("Delete") }
//                ]
//            )
//        }
//
//        await sut.send(.confirmationDialog(.presented(.confirmMarkInProgress(task2)))) {
//            $0.confirmationDialog = nil
//            $0.alert = .init(
//                title: TextState("Mark Task2 in progress?"),
//                message: TextState("This will also complete previous tasks and timer sessions."),
//                buttons: [
//                    ButtonState(action: .markInProgress(task2)) {
//                        TextState("Confirm")
//                    },
//                    ButtonState(role: .cancel) {
//                        TextState("Cancel")
//                    }
//                ]
//            )
//        }
//
//        var updatedTasks = [task1, task2]
//        updatedTasks[0].completed = true
//        updatedTasks[0].inProgress = false
//        updatedTasks[1].inProgress = true
//        await sut.send(.alert(.presented(.markInProgress(task2)))) {
//            $0.alert = nil
//            $0.list.tasks = updatedTasks
//        }
//
//        await sut.receive(.delegate(.didSaveList(sut.state.list)))
//    }
//}
