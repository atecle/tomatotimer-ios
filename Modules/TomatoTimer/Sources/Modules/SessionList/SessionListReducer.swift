import Foundation
import ComposableArchitecture

struct SessionListReducer: ReducerProtocol {

    // MARK: - Definitions

    enum CancelID: Hashable {
        case fetch
    }

    enum Action: Equatable {
        case viewDidAppear
        case setList(SessionList)
        case setProject(FocusProject)
        case toggleCompleted(FocusListTask)
        case updateTitle(for: FocusListTask, title: String)
        case listRowMenuButtonPressed(FocusListTask)

        // Navigation
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case delete(FocusListTask)
            case toggleCompleted(FocusListTask)
            case markInProgress(FocusListTask)
        }

        enum ConfirmationDialog: Equatable {
            case confirmMarkInProgress(FocusListTask)
            case confirmDeleteTask(FocusListTask)
        }
    }

    struct State: Equatable {
        var list: SessionList
        var project: FocusProject

        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.focusProjectClient) var focusProjectClient

    // MARK: - Methods

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {

            case .viewDidAppear:
                return EffectTask.cancel(id: CancelID.fetch)
                    .concatenate(
                        with: monitor(state)
                            .cancellable(id: CancelID.fetch)
                    )

            case let .setList(list):
                state.list = list
                return .none

            case let .setProject(project):
                state.project = project
                return .none

            case let .toggleCompleted(task):
                return .run { [focusProjectClient, state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.toggleCompleted(task: task)
                    }
                }

            case let .updateTitle(for: task, title: title):
                return  .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.updateTask(task, title: title)
                    }
                }

            case let .listRowMenuButtonPressed(task):
                state.confirmationDialog = .init(
                    title: TextState("What do you want to do?"),
                    buttons:
                        (task.inProgress
                         ? []
                         : [ButtonState(action: .send(.confirmMarkInProgress(task))) { TextState("Mark In Progress") }]
                        )
                    +
                    [ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task))) { TextState("Delete") }]
                )
                return .none

            case let .confirmationDialog(.presented(.confirmMarkInProgress(task))):
//                state.alert = .init(
//                    title: TextState("Mark \(task.title) in progress?"),
//                    message: TextState("This will also complete previous tasks and timer sessions."),
//                    buttons: [
//                        ButtonState(action: .markInProgress(task)) {
//                            TextState("Confirm")
//                        },
//                        ButtonState(role: .cancel, label: {
//                            TextState("Cancel")
//                        })
//                    ]
//                )
                return .run { [focusProjectClient, state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.markInProgress(task: task)
                    }
                }

            case let .confirmationDialog(.presented(.confirmDeleteTask(task))):
                state.alert = .init(
                    title: TextState("Delete \(task.title)?"),
                    message: TextState("This will also delete the timer session."),
                    buttons: [
                        ButtonState(role: .destructive, action: .delete(task)) {
                            TextState("Delete")
                        },
                        ButtonState(role: .cancel, label: {
                            TextState("Cancel")
                        })
                    ]
                )
                return .none

            case .confirmationDialog:
                return .none

            case let .alert(.presented(.delete(task))):
                guard let indexToBeDeleted = state.list.tasks.firstIndex(
                    where: { $0.id == task.id }
                ) else { return .none }

                return .run { [state, focusProjectClient] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.delete(task: state.list.tasks[indexToBeDeleted])
                    }
                }

            case let .alert(.presented(.toggleCompleted(task))):
                return .run { [state, focusProjectClient] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.toggleCompleted(task: task)
                    }
                }

            case let .alert(.presented(.markInProgress(task))):
                return .run { [state, focusProjectClient] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.markInProgress(task: task)
                    }
                }

            case .alert:
                return .none

            }
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .ifLet(\.$alert, action: /Action.alert)
    }

    // MARK: Helper

    func monitor(_ state: State) -> EffectTask<Action> {
        return .merge(
            monitor(state.list),
            monitor(state.project)
        )
    }

    func monitor(_ list: SessionList) -> EffectTask<Action> {
        return services.focusListService.monitor(.session(list))
            .catchToEffect().map { result in
                switch result {
                case let .success(.session(list)):
                    return .setList(list)
                default:
                    fatalError()
                }
            }
    }

    func monitor(_ project: FocusProject) -> EffectTask<Action> {
        return focusProjectClient.monitorProjectWithID(project.id)
            .catchToEffect().map { result in
                switch result {
                case let .success(project):
                    return .setProject(project)
                default:
                    fatalError()
                }
            }
    }
}
