//import XCTest
//import ComposableArchitecture
//
//@testable import TomatoTimer
//@MainActor
//
//final class FocusProjectReducerTests: XCTestCase {
//
//    func test_segmented_control_selection_changed_sets_segmented_control_selection() async {
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(),
//            reducer: FocusProjectReducer()
//        )
//
//        await sut.send(.segmentedControlSelectionChanged(.list)) {
//            $0.segmentedControlSelection = .list
//        }
//    }
//
//    func test_timer_menu_button_pressed_shows_confirmation_dialog() async {
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(),
//            reducer: FocusProjectReducer()
//        )
//
//        sut.dependencies.services = MockServices()
//        await sut.send(.timerMenuButtonPressed) {
//            $0.confirmationDialog = .init(title: {
//                TextState("What do you want to do?")
//            }, actions: {
//                ButtonState(action: .send(.restartTimer)) {
//                    TextState("Restart Timer")
//                }
//                ButtonState(action: .send(.restartSession)) {
//                    TextState("Restart Session")
//                }
//                ButtonState(action: .send(.completeSession)) {
//                    TextState("Complete Session")
//                }
//            })
//        }
//    }
//
//    func test_on_commit_empty_state_when_single_task_should_add_task() async {
//        let uuid = UUID()
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(
//                project: FocusProject(
//                    list: .singleTask(.init(id: uuid)),
//                    timer: .standard(.init(id: uuid))
//                ),
//                timer: .init(timer: .standard(.init(id: uuid)))
//            ),
//            reducer: FocusProjectReducer()
//        )
//
//        sut.dependencies.services = MockServices()
//        sut.dependencies.uuid = .constant(uuid)
//        let task = FocusListTask(id: uuid, title: "Task", completed: false, inProgress: true, elapsed: 0)
//        await sut.send(.onCommitEmptyState("Task")) {
//            $0.project.list = .singleTask(.init(id: uuid, task: task))
//        }
//    }
//
//    func test_on_commit_empty_state_when_single_task_should_add_task_multiple_tasks() async {
//        let timerUUID = UUID()
//        let uuid1 = UUID()
//        let uuid2 = UUID()
//        let existingTask = FocusListTask(id: uuid1, title: "Existing", completed: true, inProgress: false, elapsed: 0)
//        let project = FocusProject(
//            list: .singleTask(.init(id: uuid1, task: existingTask)),
//            timer: .standard(.init(id: timerUUID))
//        )
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(
//                project: project,
//                timer: .init(timer: .standard(.init(id: timerUUID)))
//            ),
//            reducer: FocusProjectReducer()
//        )
//        sut.dependencies.services = MockServices()
//        sut.dependencies.uuid = .constant(uuid2)
//        let task = FocusListTask(id: uuid2, title: "Task", completed: false, inProgress: true, elapsed: 0)
//        await sut.send(.onCommitEmptyState("Task")) {
//            $0.project.list = .singleTask(.init(id: uuid1, task: task))
//        }
//    }
//
//    func test_on_commit_empty_state_standard_list_should_add_task() async {
//        let timer: FocusTimer = .standard(StandardTimer())
//        let uuid = UUID()
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(
//                timer: .init(timer: timer, list: .standard(.init())),
//                list: FocusListReducer.State(timerList: .standard(.init(id: uuid)))
//            ),
//            reducer: FocusProjectReducer()
//        )
//        sut.dependencies.services = MockServices()
//        sut.dependencies.uuid = .constant(uuid)
//        let task = FocusListTask(id: uuid, title: "Task", completed: false, inProgress: true, elapsed: 0)
//        await sut.send(.onCommitEmptyState("Task")) {
//            $0.project.list = .standard(.init(id: $0.project.list.id, tasks: [task]))
//        }
//        await sut.receive(.list(.reload))
//        await sut.receive(.list(.standard(.reload)))
//        await sut.receive(.list(.standard(.setList(.init(id: uuid, tasks: [])))))
//    }
//
//    func test_on_commit_task_view_should_update_current_task() async {
//        let uuid = UUID()
//        let task = FocusListTask(id: uuid, title: "Task", completed: false, inProgress: true, elapsed: 0)
//        let standardList = StandardList(id: uuid, tasks: [task])
//        let sut = TestStoreOf<FocusProjectReducer>(
//            initialState: FocusProjectReducer.State(
//                project: .init(list: .standard(standardList)),
//                list: .standard(.init(list: standardList))
//            ),
//            reducer: FocusProjectReducer()
//        )
//        let services = MockServices()
//        sut.dependencies.services = services
//        sut.dependencies.uuid = .constant(uuid)
//        await sut.send(.onCommitTaskView("title")) {
//            $0.project.list.updateCurrentTask(with: "title")
//        }
//        await sut.receive(.list(.reload))
//        await sut.receive(.list(.standard(.reload)))
//        await sut.receive(.list(.standard(.setList(standardList))))
//    }
//
////    func test_on_commit_plus_button_should_create_in_progress_task_if_none_in_progress() async {
////        let uuid = UUID()
////        let completedTasks = 3.timesMap { _ in FocusListTask(completed: true) }
////        let timer: FocusTimer = .standard(StandardTimer())
////        let standardList = StandardList(id: uuid, tasks: completedTasks)
////        let sut = TestStoreOf<FocusProjectReducer>(
////            initialState: FocusProjectReducer.State(
////                timer: .init(timer: timer, incompleteTaskCount: 0),
////                list: .standard(.init(list: standardList))
////            ),
////            reducer: FocusProjectReducer()
////        )
////
////        sut.dependencies.uuid = .constant(uuid)
////        sut.dependencies.services = MockServices()
////        let task = FocusListTask(id: uuid, title: "Title", completed: false, inProgress: true, elapsed: 0)
////        await sut.send(.onCommitPlusButton("Title"))
////        await sut.receive(.list(.createTask(task)))
////        await sut.receive(.list(.standard(.addTask(task)))) {
////            $0.list = .standard(.init(list: .init(id: uuid, tasks: completedTasks + [task])))
////        }
////        await sut.receive(.list(.standard(.delegate(.didSaveList(.init(id: uuid, tasks: completedTasks + [task])))))) {
////            $0.project.list = .standard(.init(id: uuid, tasks: completedTasks + [task]))
////        }
////        await sut.receive(.timer(.updateIncompleteTaskCount(1)))
////        await sut.receive(.timer(.standard(.updateIncompleteTaskCount(1)))) {
////            $0.timer = .init(timer: timer, incompleteTaskCount: 1)
////        }
////    }
//
////    func test_on_commit_plus_button_should_send_create_task_action_and_add_session_if_using_session_list() async {
////        let uuid = UUID()
////        let existingTask = FocusListTask(id: uuid, title: "existing", completed: false, inProgress: false, elapsed: 0)
////        let config = StandardTimerConfiguration(sessionCount: 1)
////        let timer = StandardTimer(id: uuid, config: config)
////        let sut = TestStoreOf<FocusProjectReducer>(
////            initialState: FocusProjectReducer.State(
////                project: FocusProject(list: .session(.init(id: uuid, tasks: [existingTask]))),
////                timer: .standard(.init(timer: timer)),
////                list: .session(.init(list: .init(id: uuid, tasks: [existingTask])))
////            ),
////            reducer: FocusProjectReducer()
////        )
////
////        let uuid2 = UUID()
////        sut.dependencies.uuid = .constant(uuid2)
////        sut.dependencies.services = MockServices()
////        let task = FocusListTask(id: uuid2, title: "Title", completed: false, inProgress: true, elapsed: 0)
////        await sut.send(.onCommitPlusButton("Title"))
////        await sut.receive(.list(.createTask(task)))
////        await sut.receive(.timer(.addSession))
////        await sut.receive(.list(.session(.addTask(task)))) {
////            $0.list = .session(.init(list: .init(id: uuid, tasks: [existingTask, task])))
////        }
////
////        let newConfig = StandardTimerConfiguration(sessionCount: 2)
////        await sut.receive(.timer(.standard(.addSession))) {
////            $0.timer = .standard(.init(timer: .init(id: uuid, config: newConfig)))
////        }
////
////        await sut.receive(.list(.session(.delegate(.didSaveList(.init(id: uuid, tasks: [existingTask, task])))))) {
////            $0.project.list = .session(.init(id: uuid, tasks: [existingTask, task]))
////        }
////        await sut.receive(.timer(.updateIncompleteTaskCount(2)))
////        await sut.receive(.timer(.standard(.updateIncompleteTaskCount(2)))) {
////            $0.timer = .standard(.init(timer: .init(id: uuid, config: .init(sessionCount: 2)), incompleteTaskCount: 2))
////        }
////    }
//
////    func test_completing_task_when_using_preset_list_should_complete_timer_session() async {
////        let task1 = TimerListTask(id: UUID(), title: "Task1", inProgress: true)
////        let task2 = TimerListTask(id: UUID(), title: "Task2")
////        let task3 = TimerListTask(id: UUID(), title: "Task3")
////        let task4 = TimerListTask(id: UUID(), title: "Task4")
////        let timer = StandardTimer()
////        let sut = TestStoreOf<TimerHomeReducer>(
////            initialState: TimerHomeReducer.State(
////                project: .init(list: .preset([
////                    task1,
////                    task2,
////                    task3,
////                    task4
////                ])),
////                timer: .init(timer: .standard(timer)),
////                list: .preset(.init(tasks: [task1, task2, task3, task4]))
////            ),
////            reducer: TimerHomeReducer()
////        )
////        let clock = ImmediateClock()
////        sut.dependencies.continuousClock = clock
////        var updatedTasks = [task1, task2, task3, task4]
////        updatedTasks[0].completed = true
////        updatedTasks[0].inProgress = false
////        updatedTasks[1].inProgress = true
////        await sut.send(.complete(task1))
////        await sut.receive(.setTaskViewCompletionButtonScale(1.4)) {
////            $0.taskViewCompletionButtonScale = 1.4
////        }
////        await sut.receive(.setTaskViewOpacity(0)) {
////            $0.taskViewOpacity = 0
////        }
////        await sut.receive(.list(.completeCurrentTask))
////        await sut.receive(.setTaskViewCompletionButtonScale(0)) {
////            $0.taskViewCompletionButtonScale = 0
////        }
////
////        await sut.receive(.list(.preset(.completeCurrentTask)))
////        await sut.receive(.list(.preset(.toggleCompleted(task1)))) {
////            $0.list = .preset(.init(tasks: updatedTasks))
////        }
////        await sut.receive(.list(.preset(.delegate(.completeSession))))
////        await sut.receive(.setTaskViewOpacity(1)) {
////            $0.taskViewOpacity = 1
////        }
////        await sut.receive(.list(.preset(.delegate(.didSaveTasks(updatedTasks))))) {
////            $0.project.list = .preset(updatedTasks)
////            $0.list = .preset(.init(tasks: updatedTasks))
////        }
////        await sut.receive(.timer(.complete))
////        await sut.receive(.timer(.updateIncompleteTaskCount(3)))
////
////        await sut.receive(.timer(.standard(.complete(toNextWorkSession: true))))
////        await sut.receive(.timer(.standard(.updateIncompleteTaskCount(3)))) {
////            $0.timer = .standard(.init(timer: .init(), incompleteTaskCount: 3))
////        }
////
////        await sut.receive(.setTaskViewOpacity(1)) {
////            $0.taskViewOpacity = 1
////        }
////    }
//
////    func test_complete_when_single_task_marks_complete() async {
////        let uuid = UUID()
////        let task = FocusListTask(id: uuid, title: "Task")
////        let sut = TestStoreOf<FocusProjectReducer>(
////            initialState: FocusProjectReducer.State(
////                project: .init(list: .singleTask(.init(id: uuid, task: task)))
////            ),
////            reducer: FocusProjectReducer()
////        )
////
////        var updatedTask = task
////        updatedTask.completed = true
////        let testClock = TestClock()
////        sut.dependencies.services = MockServices()
////        sut.dependencies.continuousClock = testClock
////        sut.dependencies.uuid = .constant(uuid)
////        await sut.send(.completeSingleTask) {
////            $0.project.list = .singleTask(.init(id: uuid, task: updatedTask))
////        }
////        await sut.receive(.timer(.updateIncompleteTaskCount(0)))
////        await sut.receive(.timer(.standard(.updateIncompleteTaskCount(0))))
////    }
//}
