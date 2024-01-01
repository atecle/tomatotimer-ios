import Foundation
import ComposableArchitecture
import ComposableUserNotifications
import SwiftUINavigation

struct TomatoTimerHomeReducer: ReducerProtocol {

    // MARK: - Definitions

    struct State: Equatable {

        // View State
        var taskCompleted = false
        var taskOpacity: Double = 1

        // Shared
        var allProjects: [TodoListProject] = []
        var currentProjectShared = TodoListProject()
        var settingsShared = Settings()
        var tomatoTimer: TomatoTimer {
            get { timer.tomatoTimer }
            set { timer.tomatoTimer = newValue }
        }

        // Child State
        var timer: TomatoTimerReducer.State = .init()

        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState var settings: ClassicSettingsReducer.State?
        @PresentationState var taskInput: TaskInputReducer.State?
        @PresentationState var planner: PlannerHomeReducer.State?
        @PresentationState var debug: DebugReducer.State?
    }

    enum Action: Equatable {
        // Load
        case viewDidAppear
        case loadSettings(Settings)
        case loadCurrentProject(TodoListProject)
        case loadProjects([TodoListProject])
        case didMigratePurchases

        // View Actions
        case markTaskCompleted
        case markTaskUncompleted
        case completeCurrentTask
        case setTaskOpacity(Double)
        case settingsButtonPressed
        case menuButtonPressed
        case focusTaskButtonPressed
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        // Child
        case timer(TomatoTimerReducer.Action)
        case settings(PresentationAction<ClassicSettingsReducer.Action>)
        case taskInput(PresentationAction<TaskInputReducer.Action>)
        case planner(PresentationAction<PlannerHomeReducer.Action>)
        case debug(PresentationAction<DebugReducer.Action>)

        enum ConfirmationDialog {
            case restartTimer
            case restartSession
            case completeSession
            case showDebug
        }
    }

    // MARK: - Properties

    // MARK: Dependency

    @Dependency(\.date) var date
    @Dependency(\.continuousClock) var clock
    @Dependency(\.services) var services
    @Dependency(\.uiApplication) var uiApplication

    // MARK: Reducer

    var body: some ReducerProtocolOf<Self> {
        Scope(state: \.timer, action: /Action.timer) {
            TomatoTimerReducer()
        }
        Reduce { state, action in
            switch action {
                // MARK: Ignored Child Actions

            case .timer, .settings, .taskInput, .planner, .debug:
                return .none

                // MARK: Load

            case .viewDidAppear:
                return fetch()

            case .didMigratePurchases:
                state.settingsShared.purchasedPro = true
                return .run { [state] _ in
                    try await services.settingsService.update(state.settingsShared)
                }

            case let .loadSettings(settings):
                state.settingsShared = settings
                uiApplication.isIdleTimerDisabled = settings.keepDeviceAwake
                return .none

            case let .loadCurrentProject(project):
                state.currentProjectShared = project
                return .none

            case let .loadProjects(projects):
                state.allProjects = projects
                return .none

                // MARK: Timer Home Root View

            case .markTaskCompleted:
                state.taskCompleted = true
                return .merge(
                    .run { [clock] send in
                        await send(.setTaskOpacity(0))
                        try await clock.sleep(for: .milliseconds(100))
                        await send(.completeCurrentTask)
                        await send(.setTaskOpacity(1))
                        await send(.markTaskUncompleted)
                    },
                    save(state.currentProjectShared)
                )

            case .completeCurrentTask:
                state.currentProjectShared.completeCurrentTask()
                return save(state.currentProjectShared)

            case .markTaskUncompleted:
                state.taskCompleted = false
                return .none

            case let .setTaskOpacity(opacity):
                state.taskOpacity = opacity
                return .none

            case .settingsButtonPressed:
                state.settings = .init(
                    timer: state.tomatoTimer,
                    settings: state.settingsShared
                )
                return .none

            case .menuButtonPressed:
                let isDebug: Bool
                #if DEBUG
                isDebug = true
                #else
                isDebug = false
                #endif
                state.confirmationDialog = .init(title: {
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
                    if isDebug {
                        ButtonState(action: .send(.showDebug)) {
                            TextState("Debug")
                        }
                    }
                })
                return .none

            case .focusTaskButtonPressed:
                if state.settingsShared.usingTodoList {
                    state.planner = PlannerHomeReducer.State(
                        project: state.currentProjectShared,
                        allProjects: state.allProjects
                    )
                } else {
                    state.taskInput = TaskInputReducer.State(
                        settings: state.settingsShared,
                        project: state.currentProjectShared
                    )
                }
                return .none

            case let .confirmationDialog(.presented(action)):
                switch action {
                case .restartTimer:
                    return .task {
                        .timer(.restartTimer)
                    }
                case .restartSession:
                    return .task {
                        .timer(.restartSession)
                    }
                case .completeSession:
                    return .task {
                        .timer(.complete)
                    }
                case .showDebug:
                    state.debug = DebugReducer.State()
                    return .none
                }
            case .confirmationDialog:
                return .none
            }
        }
        .ifLet(\.$taskInput, action: /Action.taskInput) {
            TaskInputReducer()
        }
        .ifLet(\.$planner, action: /Action.planner) {
            PlannerHomeReducer()
        }
        .ifLet(\.$settings, action: /Action.settings) {
            ClassicSettingsReducer()
        }
        .ifLet(\.$debug, action: /Action.debug) {
            DebugReducer()
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
    }

    // MARK: - Methods

    func save(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.update(project)
        }
    }

    func fetch() -> EffectTask<Action> {
        return .merge(
            services.settingsService.settings().catchToEffect()
                .map {
                    switch $0 {
                    case let .success(settings):
                        return .loadSettings(settings)
                    default:
                        fatalError()
                    }
                },
            services.projectService.currentProject().catchToEffect()
                .map {
                    switch $0 {
                    case let .success(project):
                        return .loadCurrentProject(project)
                    default:
                        fatalError()
                    }
                },
            services.projectService.monitor().catchToEffect()
                .map {
                    switch $0 {
                    case let .success(projects):
                        return .loadProjects(projects)
                    default:
                        fatalError()
                    }
                }
        )
    }
}
