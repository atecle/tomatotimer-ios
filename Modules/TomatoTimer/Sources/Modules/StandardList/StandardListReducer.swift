import Foundation
import ComposableArchitecture

struct StandardListReducer: ReducerProtocol {

    // MARK: - Definitions

    enum CancelID: Hashable {
        case monitorList
        case monitorProject
    }

    enum Action: Equatable {
        // View Actions
        case viewDidAppear
        case setList(StandardList)
        case setProject(FocusProject)
        case addTaskEmptyStatePressed
        case onCommitAddTaskEmptyState(String)
        case updateTitle(for: FocusListTask, title: String)
        case toggleCompleted(FocusListTask)
        case move(from: IndexSet, to: Int)
        case listRowMenuButtonPressed(FocusListTask)

        // Navigation

        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case alert(PresentationAction<Alert>)

        enum ConfirmationDialog: Equatable {
            case toggleInProgress(FocusListTask)
            case confirmDeleteTask(FocusListTask)
        }

        enum Alert: Equatable {
            case delete(FocusListTask)
        }
    }

    struct State: Equatable {
        var list: StandardList
        var project: FocusProject
        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    // MARK: - Properties

    @Dependency(\.uuid) var uuid
    @Dependency(\.services) var services
    @Dependency(\.focusProjectClient) var focusProjectClient
//    @Dependency(\.focusListTaskClient) var focusListTaskClient
    @Dependency(\.standardListClient) var standardListClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return monitor(state)

            case let .setList(list):
                state.list = list
                return .none

            case let .setProject(project):
                state.project = project
                return .none

            case .addTaskEmptyStatePressed:
                return .none

            case let .onCommitAddTaskEmptyState(title):
                guard !title.isEmpty else { return .none }
                let task = FocusListTask(id: uuid(), title: title, inProgress: true)
                return .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.addTask(task: task)
                    }
                }

            case let .updateTitle(for: task, title: title):
                return  .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.updateTask(task, title: title)
                    }
                }

            case let .toggleCompleted(task):
                return .run { [state, focusProjectClient] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.toggleCompleted(task: task)
                    }
                }

            case let .move(indexSet, offset):
                return .run { [state, standardListClient] _ in
                    try await standardListClient.moveTaskFromOffsetsToOffset(state.list.id, (indexSet, offset))
                }

            case let .listRowMenuButtonPressed(task):
                state.confirmationDialog = .init(
                    title: TextState("What do you want to do?"),
                    buttons:
                        (task.inProgress || task.completed
                         ? []
                         : [ButtonState(action: .send(.toggleInProgress(task))) { TextState("Mark In Progress") }]
                        )
                        +
                        [ButtonState(role: .destructive, action: .send(.confirmDeleteTask(task))) { TextState("Delete") }]
                )
                return .none

            case let .confirmationDialog(.presented(.toggleInProgress(task))):
                return .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.markInProgress(task: task)
                    }
                }

            case let .confirmationDialog(.presented(.confirmDeleteTask(task))):
                state.alert = .init(
                    title: TextState("Are you sure you want to delete this task?"), buttons: [
                        ButtonState(role: .destructive, action: .delete(task)) {
                            TextState("Delete")
                        }
                    ]
                )
                return .none

            case .confirmationDialog:
                return .none

            case let .alert(.presented(.delete(task))):
                return .run { [state] _ in
                    try await focusProjectClient.update(state.project.id) { project in
                        project.delete(task: task)
                    }
                }

            case .alert:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .ifLet(\.$alert, action: /Action.alert)
    }

    func monitor(_ state: State) -> EffectTask<Action> {
        .merge(
            monitor(state.list),
            monitor(state.project)
        )
    }

    func monitor(_ list: StandardList) -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.monitorList)
           .concatenate(
               with: standardListClient.monitorListWithID(list.id)
                   .catchToEffect().map { result -> Action in
                       switch result {
                       case let .success(list):
                           return .setList(list)
                       default:
                           fatalError()
                       }
                   }
                   .cancellable(id: CancelID.monitorList)
           )
    }

    func monitor(_ project: FocusProject) -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.monitorProject)
           .concatenate(
               with: focusProjectClient.monitorProjectWithID(project.id)
                   .catchToEffect().map { result -> Action in
                       switch result {
                       case let .success(list):
                           return .setProject(list)
                       default:
                           fatalError()
                       }
                   }
                   .cancellable(id: CancelID.monitorProject)
           )
    }
}
