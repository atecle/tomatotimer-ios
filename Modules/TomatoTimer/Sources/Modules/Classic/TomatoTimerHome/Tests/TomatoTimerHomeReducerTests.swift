import XCTest
import ComposableArchitecture
import ComposableUserNotifications
@testable import TomatoTimer

@MainActor
final class TomatoTimerHomeRootReducerTests: XCTestCase {

    func test_markTaskCompleted() async {
        let task = TodoListTask(inProgress: true)
        let project = TodoListProject(isActive: true, tasks: [task])
        let sut = createTestDeps(project: project)
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        await sut.send(.markTaskCompleted) {
            $0.taskCompleted = true
        }
        await sut.receive(.setTaskOpacity(0)) {
            $0.taskOpacity = 0
        }
        await sut.receive(.completeCurrentTask) {
            $0.currentProjectShared.completeCurrentTask()
        }
        await sut.receive(.setTaskOpacity(1)) {
            $0.taskOpacity = 1
        }
        await sut.receive(.markTaskUncompleted) {
            $0.taskCompleted = false
        }
    }

    func test_settingsButtonPressed() async {
        let sut = createTestDeps()
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        await sut.send(.settingsButtonPressed) {
            $0.settings = .init(timer: sut.state.tomatoTimer, settings: sut.state.settingsShared)
        }
    }

    func test_menuButtonPressed() async {
        let sut = createTestDeps()
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        await sut.send(.menuButtonPressed) {
            $0.confirmationDialog = .init(title: {
                TextState("What do you want to do?")
            }, actions: {
                ButtonState(action: .send(.restartTimer)) {
                    TextState("Restart Timer")
                }
                ButtonState(action: .send(.restartSession)) {
                    TextState("Restart Session")
                }
                ButtonState(action: .send(.completeSession)) {
                    TextState("Complete Session")
                }
                ButtonState(action: .send(.showDebug)) {
                    TextState("Debug")
                }
            })
        }
    }

    func test_focusTaskButtonPressed_should_present_task_input_if_not_using_todo_list() async {
        let sut = createTestDeps(settings: .init(usingTodoList: true))
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        await sut.send(.focusTaskButtonPressed) {
            $0.planner = PlannerHomeReducer.State(
                project: sut.state.currentProjectShared,
                allProjects: sut.state.allProjects
            )
        }
    }

    func test_focusTaskButtonPressed_should_present_todo_list_if_not_using_task_input() async {
        let sut = createTestDeps(settings: .init(usingTodoList: false))
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        await sut.send(.focusTaskButtonPressed) {
            $0.taskInput = TaskInputReducer.State(
                settings: sut.state.settingsShared,
                project: sut.state.currentProjectShared
            )
        }
    }

    func test_confirmationDialogAction_restartTimer() async {
        let sut = createTestDeps(settings: .init(usingTodoList: false))
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}

        await sut.send(.menuButtonPressed) {
            $0.confirmationDialog = .init(title: {
                TextState("What do you want to do?")
            }, actions: {
                ButtonState(action: .send(.restartTimer)) {
                    TextState("Restart Timer")
                }
                ButtonState(action: .send(.restartSession)) {
                    TextState("Restart Session")
                }
                ButtonState(action: .send(.completeSession)) {
                    TextState("Complete Session")
                }
                ButtonState(action: .send(.showDebug)) {
                    TextState("Debug")
                }
            })
        }
        await sut.send(.confirmationDialog(.presented(.restartTimer))) {
            $0.confirmationDialog = nil
        }
        await sut.receive(.timer(.restartTimer))
    }

    func test_confirmationDialogAction_restartSession() async {
        let sut = createTestDeps(settings: .init(usingTodoList: false))
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}

        await sut.send(.menuButtonPressed) {
            $0.confirmationDialog = .init(title: {
                TextState("What do you want to do?")
            }, actions: {
                ButtonState(action: .send(.restartTimer)) {
                    TextState("Restart Timer")
                }
                ButtonState(action: .send(.restartSession)) {
                    TextState("Restart Session")
                }
                ButtonState(action: .send(.completeSession)) {
                    TextState("Complete Session")
                }
                ButtonState(action: .send(.showDebug)) {
                    TextState("Debug")
                }
            })
        }
        await sut.send(.confirmationDialog(.presented(.restartSession))) {
            $0.confirmationDialog = nil
        }
        await sut.receive(.timer(.restartSession))
    }

    func test_confirmationDialogAction_completeSession() async {
        let sut = createTestDeps(settings: .init(usingTodoList: false))
        let testClock = ImmediateClock()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}

        await sut.send(.menuButtonPressed) {
            $0.confirmationDialog = .init(title: {
                TextState("What do you want to do?")
            }, actions: {
                ButtonState(action: .send(.restartTimer)) {
                    TextState("Restart Timer")
                }
                ButtonState(action: .send(.restartSession)) {
                    TextState("Restart Session")
                }
                ButtonState(action: .send(.completeSession)) {
                    TextState("Complete Session")
                }
                ButtonState(action: .send(.showDebug)) {
                    TextState("Debug")
                }
            })
        }
        await sut.send(.confirmationDialog(.presented(.completeSession))) {
            $0.confirmationDialog = nil
        }
        await sut.receive(.timer(.complete)) {
            $0.tomatoTimer.complete()
        }
    }

    func createTestDeps(
        timer: TomatoTimer = .init(),
        settings: Settings = .init(),
        project: TodoListProject = .init(),
        mockServices: MockServices = .init()
    ) -> (
        TestStore<TomatoTimerHomeReducer.State, TomatoTimerHomeReducer.Action, TomatoTimerHomeReducer.State, TomatoTimerHomeReducer.Action, ()>
    ) {
        let store = TestStore(
            initialState: TomatoTimerHomeReducer.State(
                currentProjectShared: project,
                settingsShared: settings,
                timer: TomatoTimerReducer.State(tomatoTimer: timer)
            ),
            reducer: TomatoTimerHomeReducer()
        )

        store.dependencies.services = mockServices

        return (store)
    }

}
