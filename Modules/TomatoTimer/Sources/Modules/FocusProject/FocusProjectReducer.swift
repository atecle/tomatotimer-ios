import Foundation
import ComposableArchitecture

struct FocusProjectReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        // Load
        case viewDidAppear
        case setProject(FocusProject)
        case handleBackgroundModeIfNeeded
        case suspendBackgroundMode

        // View
        case segmentedControlSelectionChanged(State.SegmentedControl)
        case timerMenuButtonPressed
        case listPlusButtonPressed
        case addTaskEmptyStatePressed
        case selectTaskEmptyStatePressed
        case onCommitEmptyState(String)
        case onCommitTaskView(String)
        case onCommitPlusButton(String)
        case taskViewCompleteButtonPressed(FocusListTask)
        case resumeProjectButtonPressed

        // Animation
        case setTaskViewCompletionButtonScale(CGFloat)
        case setTaskViewOpacity(CGFloat)

        // Presentation
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case debug(PresentationAction<DebugReducer.Action>)

        // Child
        case timer(TimerReducer.Action)
        case list(FocusListReducer.Action)

        enum ConfirmationDialog: Equatable {
            case restartTimer
            case restartSession
            case completeSession
            case showDebug
        }
    }

    struct State: Equatable {
        var segmentedControlSelection: SegmentedControl = .timer
        var project: FocusProject = .init()
        var currentTask: FocusListTask? {
            project.list.tasks.first(where: \.inProgress)
        }

        var taskViewCompletionButtonScale: CGFloat = 0
        var taskViewOpacity: CGFloat = 1

        var timer: TimerReducer.State = .init()
        var list: FocusListReducer.State?

        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState var debug: DebugReducer.State?

        enum SegmentedControl: Equatable {
            case timer
            case list
        }
    }

    // MARK: - Properties

    // MARK: Dependencies

    @Dependency(\.continuousClock) var clock
    @Dependency(\.services) var services
    @Dependency(\.uuid) var uuid
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.mainQueue) var mainQueue

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Scope(state: \.timer, action: /Action.timer) {
            TimerReducer()
        }
        Reduce { state, action in
            switch action {

                // MARK: Load

            case .viewDidAppear:
                return focusProjectClient
                    .monitorProjectWithID(state.project.id)
                    .catchToEffect().map { result in
                        switch result {
                        case let .success(project):
                            return .setProject(project)
                        default:
                            fatalError()
                        }
                    }

            case let .setProject(project):
                state.project = project
                return .none

            case .handleBackgroundModeIfNeeded:
                return .merge(
                    .task { .timer(.handleBackgroundMode) }
                )

            case .suspendBackgroundMode:
                return .merge(
                    .task { .timer(.suspendBackgroundMode) }
                )

                // MARK: View Actions

            case let .segmentedControlSelectionChanged(selection):
                state.segmentedControlSelection = selection
                return .none

            case .timerMenuButtonPressed:
                state.confirmationDialog = .init(title: {
                    TextState("What do you want to do?")
                }, actions: {
                    ButtonState(action: .send(.restartTimer)) {
                        TextState("Restart Timer")
                    }
                    ButtonState(action: .send(.restartSession)) {
                        TextState("Restart Session")
                    }
                    if state.project.timer.isStandard {
                        ButtonState(action: .send(.completeSession)) {
                            TextState("Complete Session")
                        }
                    }
                })
                return .none

            case .listPlusButtonPressed, .selectTaskEmptyStatePressed, .addTaskEmptyStatePressed:
                return .none

            case let .onCommitEmptyState(title):
                guard !title.isEmpty else { return .none }
                let task = FocusListTask(id: uuid(), title: title, completed: false, inProgress: true)
                return .run { [state, focusProjectClient] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.addTask(task: task)
                    }
                }

            case let .onCommitTaskView(text):
                return .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.list.updateCurrentTask(with: text)
                    }
                }

            case let .onCommitPlusButton(title):
                guard !title.isEmpty else { return .none }
                let inProgress: Bool = state.project.list.tasks.filter(\.inProgress).count == 0
                let task = FocusListTask(id: uuid(), title: title, completed: false, inProgress: inProgress)
                return .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.addTask(task: task)
                    }
                }

            case .taskViewCompleteButtonPressed:
                return .run { [state] send in
                    await send(.setTaskViewCompletionButtonScale(1.4))
                    try await clock.sleep(for: .milliseconds(700))
                    await send(.setTaskViewOpacity(0))
                    try await clock.sleep(for: .milliseconds(200))

                    try await focusProjectClient.update(state.project.id) { project in
                        project.completeCurrentTask()
                    }

                    await send(.setTaskViewCompletionButtonScale(0))
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.setTaskViewOpacity(1))
                }

            case .resumeProjectButtonPressed:
                return .run { [focusProjectClient, state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.uncomplete()
                    }
                }

                // Animations
            case let .setTaskViewCompletionButtonScale(scale):
                state.taskViewCompletionButtonScale = scale
                return .none

            case let .setTaskViewOpacity(opacity):
                state.taskViewOpacity = opacity
                return .none

                // Presentation
            case let .confirmationDialog(.presented(action)):

                switch action {
                case .restartTimer:
                    return .run { [state, focusProjectClient] _ in
                        try await focusProjectClient.update(state.project.id) { project in
                            project.restartTimer()
                        }
                    }

                case .restartSession:
                    return .run { [state, focusProjectClient] _ in
                        try await focusProjectClient.update(state.project.id) { project in
                            project.restartTimerSession()
                        }
                    }

                case .completeSession:
                    return .run { [state, focusProjectClient] _ in
                        try await focusProjectClient.update(state.project.id) { project in
                            project.completeTimerSession()
                        }
                    }

                case .showDebug:
                    state.debug = DebugReducer.State()
                    return .none
                }

            case .confirmationDialog:
                return .none

            case .list:
                return .none

            case .timer:
                return .none

            case .debug:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .ifLet(\.list, action: /Action.list) {
            FocusListReducer()
        }
        .ifLet(\.$debug, action: /Action.debug) {
            DebugReducer()
        }
    }
}
