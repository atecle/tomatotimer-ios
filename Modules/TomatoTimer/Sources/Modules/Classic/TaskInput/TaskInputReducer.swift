import Foundation
import ComposableArchitecture
import SwiftUI

struct TaskInputReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case setProject(TodoListProject)
        case setTask(String)
        case setEnteredText(String)
    }

    struct State: Equatable {
        var enteredText: String = ""
        var settings: Settings
        var project: TodoListProject

        var themeColor: UIColor { settings.themeColor }
    }

    // MARK: - Properties

    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    @Dependency(\.services) var services

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setProject(project):
            state.project = project
            return .none

        case let .setEnteredText(text):
            state.enteredText = text
            return .none

        case let .setTask(title):
            guard !title.isEmpty else {
                state.project.tasks = []
                return saveProjectToDisk(state.project)
            }

            if state.project.tasks.isEmpty {
                var task = TodoListTask(id: uuid(), creationDate: date.now)
                task.title = title
                task.inProgress = true
                state.project.tasks = [task]
            } else {
                state.project.tasks[0].title = title
                state.project.tasks[0].inProgress = true
            }

            return saveProjectToDisk(state.project)
        }
    }

    // MARK: Helper

    func saveProjectToDisk(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.update(project)
        }
    }

    func fetchProjectFromDisk() -> EffectTask<Action> {
        return services.projectService.currentProject().catchToEffect()
            .map {
                switch $0 {
                case let .success(project):
                    return .setProject(project)
                case .failure:
                    fatalError()
                }
            }
    }
}
