import Foundation
import ComposableArchitecture
import SwiftUINavigation
import SwiftUI

// swiftlint:disable line_length file_length

struct PlannerHomeReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        // Initial Load Actions
        case onAppear
        case loadCurrentProject(TodoListProject)
        case loadProjects([TodoListProject])

        // Confirmation Dialog
        case setIsRenameProjectAlertPresented(Bool)
        case setRenameProjectAlertTextInput(String)
        case renameProject(String)

        // Navigation Bar
        case plusButtonPressed
        case doneButtonPressed
        case menuButtonPressed

        // List Actions
        case setInProgressTask(PlannerHomeReducer.PlannerListItem)
        case completeCurrentTask
        case addTask(String, at: Int?)
        case editTask(PlannerListItem)
        case isEditingChanged(Bool, item: PlannerListItem)
        case delete(at: IndexSet)
        case move(at: IndexSet, to: Int)
        case onSubmit(PlannerListItem)
        case setFocus(PlannerListItem?)

        case dismissButtonPressed

        // Child Actions
        case projects(PresentationAction<ProjectsReducer.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        enum ConfirmationDialog: Equatable {
            case renameProject
            case switchProjects
            case toggleShowCompletedTasks
        }
    }

    struct NewTaskConfiguration: Equatable, Hashable {
        static let id = UUID()
        var index: Int
        var completed: Bool
        var inProgress: Bool
        var title: String
    }

    struct State: Equatable {

        // Stateful interactions in View
        var project: TodoListProject
        var allProjects: [TodoListProject]

        var canAddMoreTasks: Bool { project.tasks.count < 15 }
        var isEditingTextField: Bool = false
        var showEditingToolbar: Bool { isEditingTextField || newTaskConfiguration != nil }
        var isRenameProjectAlertPresented: Bool = false
        var renameProjectAlertTextInput: String = ""
        var newTaskConfiguration: NewTaskConfiguration?
        @BindingState var focus: PlannerListItem?

        // Encapsulates the state of the list
        var tasks: [PlannerListItem] {
            var computedTasks: [PlannerListItem] = (project.showCompletedTasks ? project.tasks : project.tasks.filter { !$0.completed }).map { .task($0.toUITask) }
            if let newTaskConfiguration {
                computedTasks.insert(.newTask(newTaskConfiguration), at: newTaskConfiguration.index)
            }

            return computedTasks
        }

        fileprivate var visibleTaskCount: Int {
            (project.showCompletedTasks ? project.tasks : project.tasks.filter { !$0.completed }).count
        }

        // Other State

        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState var projects: ProjectsReducer.State?
    }

    // MARK: - Properties

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .projects:
                return .none

                // MARK: - On Load

            case .onAppear:
                return fetch()

            case let .loadCurrentProject(project):
                state.project = project
                return .none

            case let .loadProjects(projects):
                state.allProjects = projects
                return .none

                // MARK: List Actions

            case .completeCurrentTask:
                state.project.completeCurrentTask()
                return save(state.project)

            case let .editTask(task):

                switch task {
                case let .newTask(config):
                    state.newTaskConfiguration = config
                case let .task(task):
                    guard let index = state.project.tasks.firstIndex(where: { task.id == $0.id }) else { return .none }
                    state.project.tasks[index].title = task.title
                    let wasCompleted = state.project.tasks[index].completed
                    state.project.tasks[index].completed = task.completed
                    state.project.tasks[index].inProgress = task.inProgress

                    if state.project.tasks[index].completed && state.project.tasks[index].inProgress {
                        // Find the next task to mark in progress
                        state.project.tasks[index].inProgress = false
                        var startIndex = index == state.project.tasks.count - 1 ? 0 : index + 1
                        while startIndex != index {
                            if state.project.tasks[startIndex].completed == false {
                                state.project.tasks[startIndex].inProgress = true
                                break
                            }

                            startIndex = startIndex == state.project.tasks.count - 1 ? 0 : startIndex + 1
                        }
                    }

                    if wasCompleted == false, task.completed {
                        let task = state.project.tasks.remove(at: index)
                        state.project.tasks.append(task)
                    }
                }

                return  save(state.project)

            case let .setFocus(focus):
                state.focus = focus
                return .none

            case let .isEditingChanged(isEditing, item):
                state.isEditingTextField = isEditing
                if isEditing {
                    state.focus = item
                } else {
                    state.focus = nil
                }
                return .none

            case let .setInProgressTask(item):
                switch item {
                case let .task(task):
                    for index in 0..<state.project.tasks.count {
                        if state.project.tasks[index].id == task.id {
                            state.project.tasks[index].inProgress = true
                        } else {
                            state.project.tasks[index].inProgress = false
                        }
                    }
                case .newTask:
                    return .none
                }

                return save(state.project)

            case let .addTask(title, index):
                guard !title.isEmpty else { return .none }
                let task = TodoListTask(id: uuid(), title: title, creationDate: date.now)
                if let index {
                    state.project.tasks.insert(task, at: index)
                } else {
                    state.project.tasks.append(task)
                }
                return save(state.project)

            case let .delete(at: indexSet):
                var tasks = state.project.tasks

                indexSet
                    .filter { tasks.indices.contains($0) }
                    .forEach { tasks.remove(at: $0) }

                state.project.tasks = tasks
                state.newTaskConfiguration?.index -= 1
                return save(state.project)

            case let .move(at: indexSet, to: row):
                state.project.tasks.move(fromOffsets: indexSet, toOffset: row)
                return save(state.project)

            case let .onSubmit(item):
                switch item {
                case let .task(task):
                    if task.title.isEmpty {
                        state.project.tasks.removeAll(where: { item.id == $0.id })
                    } else if let index = state.project.tasks.firstIndex(where: { task.id == $0.id }) {
                        guard state.canAddMoreTasks else {
                            return .none
                        }
                        let config: NewTaskConfiguration = .init(index: index + 1, completed: false, inProgress: false, title: "")
                        state.newTaskConfiguration = config
                        state.focus = .newTask(config)
                    }

                    return save(state.project)

                case let .newTask(config):
                    guard !config.title.isEmpty, state.canAddMoreTasks else {
                        state.newTaskConfiguration = nil
                        return .none
                    }

                    state.project.tasks.insert(
                        TodoListTask(title: config.title, inProgress: config.inProgress, completed: config.completed),
                        at: config.index
                    )

                    if state.canAddMoreTasks {
                        let config: NewTaskConfiguration = .init(index: config.index + 1, completed: false, inProgress: false, title: "")
                        state.newTaskConfiguration = config
                        state.focus = .newTask(config)
                    } else {
                        state.newTaskConfiguration = nil
                        state.focus = nil
                    }

                    return save(state.project)
                }

                // MARK: Navigation Bar Actions

            case .menuButtonPressed:
                state.confirmationDialog = .init(title: {
                    TextState("what do you want to do?")
                }, actions: {
                    ButtonState(action: .send(.renameProject)) {
                        TextState("Rename project")
                    }
                    ButtonState(action: .send(.switchProjects)) {
                        TextState("Switch project")
                    }
                    ButtonState(action: .send(.toggleShowCompletedTasks)) {
                        TextState(state.project.showCompletedTasks ? "Hide completed tasks" : "Show completed tasks")
                    }
                })
                return .none

            case .plusButtonPressed:
                // Edge case where plus button is pressed twice?

                let index = state.visibleTaskCount
                let config: NewTaskConfiguration = .init(index: index, completed: false, inProgress: false, title: "")
                state.newTaskConfiguration = config
                state.focus = .newTask(config)

                return .none

            case .doneButtonPressed:

                if let config = state.newTaskConfiguration, !config.title.isEmpty {
                    state.project.tasks.insert(
                        TodoListTask(title: config.title, inProgress: config.inProgress, completed: config.completed),
                        at: config.index
                    )
                }

                state.newTaskConfiguration = nil
                state.focus = nil

                return save(state.project)

                // MARK: Confirmation Dialog

            case let .confirmationDialog(.presented(action)):
                switch action {
                case .renameProject:
                    state.isRenameProjectAlertPresented = true
                    return .none

                case .switchProjects:
                    state.projects = ProjectsReducer.State(
                        currentProject: state.project,
                        projects: state.allProjects
                    )
                    return .none

                case .toggleShowCompletedTasks:
                    state.project.showCompletedTasks.toggle()
                    return save(state.project)
                }
            case .confirmationDialog:
                return .none

            case let .renameProject(title):
                guard title.isEmpty == false else { return .none }
                state.project.title = title
                state.renameProjectAlertTextInput = ""
                return save(state.project)

            case let .setIsRenameProjectAlertPresented(presented):
                state.isRenameProjectAlertPresented = presented
                return .none

            case let .setRenameProjectAlertTextInput(title):
                state.renameProjectAlertTextInput = title
                return .none

            case .dismissButtonPressed:
                return .fireAndForget { await self.dismiss() }
            }
        }
        .ifLet(\.$projects, action: /Action.projects) {
            ProjectsReducer()
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
    }

    func fetch() -> EffectTask<Action> {
        return .merge(
            services
                .projectService
                .currentProject()
                .catchToEffect()
                .map {
                    switch $0 {
                    case let .success(project):
                        return .loadCurrentProject(project)
                    default:
                        fatalError()
                    }
                },
            services
                .projectService
                .monitor()
                .catchToEffect()
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

    func save(_ project: TodoListProject) -> EffectTask<Action> {
        return .run { _ in
            try await services.projectService.update(project)
        }
    }
}

enum Focusable: Equatable, Hashable {
    case none
    case row(id: String)
}

private extension TodoListTask {
    var toUITask: PlannerHomeReducer.UITask {
        return .init(id: id, title: title, completed: completed, inProgress: inProgress)
    }
}

extension PlannerHomeReducer.State {
    var toUIState: PlannerHomeReducer.UIState {
        .init(
            showEditingToolbar: showEditingToolbar,
            isRenameProjectAlertPresented: isRenameProjectAlertPresented,
            renameProjectAlertTextInput: renameProjectAlertTextInput,
            focus: focus,
            projectTitle: project.title,
            tasks: tasks,
            canAddMoreTasks: canAddMoreTasks,
            completedTaskCount: project.tasks.filter(\.completed).count
        )
    }
}

extension PlannerHomeReducer {
    struct UIState: Equatable {
        var showEditingToolbar: Bool
        var isRenameProjectAlertPresented: Bool
        var renameProjectAlertTextInput: String
        var focus: PlannerListItem?
        let projectTitle: String
        var tasks: [PlannerListItem]
        var canAddMoreTasks: Bool
        var completedTaskCount: Int

        var emptyState: EmptyState? {
            guard tasks.count == 0 else { return nil }

            if completedTaskCount > 0 {
                return .allTasksComplete
            }

            return .noTasks
        }

        enum EmptyState: Equatable {
            case noTasks
            case allTasksComplete
        }
    }

    struct UITask: Equatable, Hashable {
        var id: UUID
        var title: String
        var completed: Bool
        var inProgress: Bool
    }

    enum PlannerListItem: Equatable, Swift.Identifiable, Hashable {
        case task(UITask)
        case newTask(NewTaskConfiguration)

        var isNewTask: Bool {
            switch self {
            case .task: return false
            case .newTask: return true
            }
        }

        private static let newTaskID = UUID()
        var id: UUID {
            switch self {
            case let .task(task): return task.id
            case .newTask: return NewTaskConfiguration.id
            }
        }

        var title: String {
            get {
                switch self {
                case let .task(task): return task.title
                case let .newTask(config): return config.title
                }
            }
            set {
                switch self {
                case var .task(task):
                    task.title = newValue
                    self = .task(task)
                case var .newTask(config):
                    config.title = newValue
                    self = .newTask(config)
                }
            }

        }

        var completed: Bool {
            get {
                switch self {
                case let .task(task): return task.completed
                case let .newTask(config): return config.completed
                }
            }
            set {
                switch self {
                case var .task(task):
                    task.completed = newValue
                    self = .task(task)
                case var .newTask(config):
                    config.completed = newValue
                    self = .newTask(config)
                }
            }
        }

        var inProgress: Bool {
            switch self {
            case let .task(task): return task.inProgress
            case .newTask: return false
            }
        }
    }
}

extension PlannerHomeReducer.UITask: Swift.Identifiable { }
