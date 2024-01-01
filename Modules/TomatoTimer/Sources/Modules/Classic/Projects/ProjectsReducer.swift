import Foundation
import ComposableArchitecture

struct ProjectsReducer: ReducerProtocol {

    enum Action: Equatable {
        case addProject(String)

        case setActive(TodoListProject)

        case deleteButtonPressed(TodoListProject)
        case setConfirmDeletionAlertPresented(Bool)
        case deleteProject
    }

    struct State: Equatable {
        var isConfirmDeletionAlertPresented: Bool = false
        var currentProject: TodoListProject
        var projects: [TodoListProject]
        var projectForDeletion: TodoListProject?
        var canAddMoreProjects: Bool { projects.count < 10 }
    }

    enum Destination: Equatable {
        case alert(AlertState<AlertAction>)
        case confirmationDialog(ConfirmationDialogState<DialogAction>)

        enum DialogAction: Equatable {
            case add
            case cancel
        }

        enum AlertAction: Equatable {}
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.services) var services

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        case let .setActive(project):
            state.currentProject = project
            var effects: [EffectTask<Action>] = []
            for index in state.projects.indices {
                if state.projects[index].id == project.id {
                    state.projects[index].isActive = true
                    effects.append(update(state.projects[index]))
                } else {
                    state.projects[index].isActive = false
                    effects.append(update(state.projects[index]))
                }
            }
            return .merge(effects)

        case let .deleteButtonPressed(project):
            state.isConfirmDeletionAlertPresented = true
            state.projectForDeletion = project
            return .none

        case let .setConfirmDeletionAlertPresented(presented):
            state.isConfirmDeletionAlertPresented = presented
            return .none

        case .deleteProject:
            guard let projectToDelete = state.projectForDeletion else { return .none }
            state.projects.removeAll(where: { $0.id == projectToDelete.id })
            return delete(projectToDelete)

        case let .addProject(title):
            guard !title.isEmpty else { return .none }
            let project = TodoListProject(id: uuid(), title: title, lastOpenedDate: date())
            state.projects.append(project)

            return add(project)
        }
    }

    func delete(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.delete(project)
        }
    }

    func update(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.update(project)
        }
    }

    func add(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.add(project)
        }
    }

}
