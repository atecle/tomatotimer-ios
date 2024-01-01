import Foundation
import ComposableArchitecture

// swiftlint:disable type_body_length
struct FocusTabReducer: ReducerProtocol {

    // MARK: - Definitions

    enum CancelID: Hashable {
        case timer
        case fetch
        case monitor
    }

    enum Action: Equatable {
        // View
        case presentNewFeaturesOnboarding
        case viewDidAppear
        case setDidPurchasePlus(Bool)
        case setTimeElapsed(Int)
        case loadDay(Date)
        case loadedProjects([FocusProject], for: Date)
        case setActiveProject(FocusProject)
        case plusButtonPressed
        case selectedProject(FocusProject)
        case toggleCompleted(FocusProject)
        case menuButtonPressed(FocusProject)

        // Navigation
        case newOnboarding(PresentationAction<NewFeaturesOnboardingReducer.Action>)
        case paywall(PresentationAction<PaywallReducer.Action>)
        case createTimer(PresentationAction<CreateFocusProjectReducer.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case activeFocusProject(FocusProjectReducer.Action)

        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case confirmDeleteProject(FocusProject)
            case presentConfirmDeleteSingleProject(FocusProject)
            case presentConfirmDeleteFollowingProjects(FocusProject)
            case presentConfirmDeleteAllProjects(FocusProject)
        }

        enum ConfirmationDialog: Equatable {
            case deleteProject(FocusProject)
            case editProject(FocusProject)
        }
    }

    struct State: Equatable {

        // Paywall
        var didPurchasePlus: Bool = false

        // Calendar state
        var currentDay: Date = .now
        var loadedProjects: [Date: [FocusProject]] = [:]
        var projectsForDate: (Date) -> [FocusProject] {
            return { date in
                return (loadedProjects[date] ?? [])
            }
        }
        var showEmptyState: (Date) -> Bool {
            return { date in
                return projectsForDate(date).count == 0
            }
        }
        var shouldSelectToday = false

        // Navigation
        var selectedFocusProject: FocusProject?
        var activeFocusProject: FocusProjectReducer.State?
        @PresentationState var newOnboarding: NewFeaturesOnboardingReducer.State?
        @PresentationState var paywall: PaywallReducer.State?
        @PresentationState var createTimer: CreateFocusProjectReducer.State?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState var alert: AlertState<Action.Alert>?
        var path = StackState<Path.State>()
    }

    struct Path: ReducerProtocol {
        enum Action: Equatable {
            case timerHome(FocusProjectReducer.Action)
        }

        enum State: Equatable {
            case timerHome(FocusProjectReducer.State)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.timerHome, action: /Action.timerHome) {
                FocusProjectReducer()
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.emoji) var emoji
    @Dependency(\.color) var color
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.services) var services
    @Dependency(\.continuousClock) var clock
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.userClient) var userClient: UserClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action -> EffectTask<Action> in
            switch action {

            case .presentNewFeaturesOnboarding:
                state.newOnboarding = .init()
                return .none

            case .viewDidAppear:
                return .merge(monitorActiveProject(), monitorDidPurchasePlus(), syncPurchasesIfNeeded())

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

            case let .setTimeElapsed(elapsed):
                return .run { [focusProjectClient] _ in
                    try await focusProjectClient.updateActiveProject { project in
                        project.setTimeElapsed(elapsed)
                    }
                }

            case let .loadDay(date):
                state.currentDay = date
                state.shouldSelectToday = false
                return monitorScheduledProjects(on: date)

            case let .loadedProjects(projects, for: date):
                state.loadedProjects[date] = projects
                return .none

            case let .setActiveProject(project):
                state.selectedFocusProject = project

                // On first load only, we have to make sure to configure a timer for background mode
                // in background after we load from disk and detect that
                // there's an active project - the timer could be running in which case,
                // we need to track time
                if state.activeFocusProject == nil {
                    state.activeFocusProject = FocusProjectReducer.State(
                        project: project,
                        timer: TimerReducer.State(
                            project: project
                        ),
                        list: FocusListReducer.State(
                            project: project
                        )
                    )

                    return state.path.count == 0 ? .task {
                        .activeFocusProject(.handleBackgroundModeIfNeeded)
                    } : .none

                }
                return .none

            case .plusButtonPressed:
                if !state.didPurchasePlus && !state.showEmptyState(Calendar.current.startOfDay(for: date())) {
                    state.paywall = .init(paywallReason: .dailyProjectLimitReached)
                    return .none
                }
                state.createTimer = CreateFocusProjectReducer.State(
                    project: .init(
                        id: uuid(),
                        creationDate: date(),
                        scheduledDate: date(),
                        emoji: emoji(),
                        themeColor: color(),
                        list: .singleTask(.init(id: uuid())),
                        timer: .standard(.init(id: uuid()))
                    ),
                    isEditing: false
                )
                return .none

            case let .selectedProject(project):
                return project.isRecurrenceTemplate
                ? handleSelectedRecurrenceTemplate(&state, project)
                : handleSelectedProject(&state, project)

            case let .toggleCompleted(project):
                return .run { [focusProjectClient] _ in
                    try await focusProjectClient.update(project.id) { project in
                        project.timer.isComplete.toggle()
                    }
                }

            case let .menuButtonPressed(project):
                state.confirmationDialog = .init(title: {
                    TextState("What do you want to do?")
                }, actions: {
                    if !project.timer.isComplete {
                        ButtonState(action: .send(.editProject(project))) {
                            TextState("Edit Project")
                        }
                    }
                    ButtonState(role: .destructive, action: .send(.deleteProject(project))) {
                        TextState("Delete")
                    }
                })
                return .none

                // Navigation
            case .createTimer(.presented(.delegate(.didCreateProject))):
                state.shouldSelectToday = true
                return .none

            case .createTimer:
                return .none

            case .path(.popFrom):
                guard let selectedProject = state.selectedFocusProject else { return .none }
                state.activeFocusProject = FocusProjectReducer.State(
                    project: selectedProject,
                    timer: TimerReducer.State(
                        project: selectedProject
                    ),
                    list: FocusListReducer.State(
                        project: selectedProject
                    )
                )
                return .task {
                    .activeFocusProject(.handleBackgroundModeIfNeeded)
                }

            case let .confirmationDialog(.presented(action)):
                switch action {
                case let .deleteProject(project):
                    if project.isRecurringInstance {
                        state.alert = .init(
                            title: TextState("Delete repeating project?"),
                            buttons: [
                                ButtonState(action: .presentConfirmDeleteSingleProject(project)) {
                                    TextState("This project only")
                                },
                                ButtonState(action: .presentConfirmDeleteFollowingProjects(project)) {
                                    TextState("This and following projects")
                                },
                                ButtonState(action: .presentConfirmDeleteAllProjects(project)) {
                                    TextState("All projects")
                                },
                                ButtonState(role: .cancel) {
                                    TextState("Cancel")
                                }
                            ]
                        )
                    } else if project.isRecurrenceTemplate {
                        state.alert = .init(
                            title: TextState("Delete all scheduled projects?"),
                            message: TextState("This will delete this scheduled project and all future scheduled projects."),
                            buttons: [
                                ButtonState(role: .destructive, action: .confirmDeleteProject(project)) {
                                    TextState("Delete")
                                }
                            ]
                        )
                    } else {
                        state.alert = .init(
                            title: TextState("Delete project?"),
                            buttons: [
                                ButtonState(role: .destructive, action: .confirmDeleteProject(project)) {
                                    TextState("Delete")
                                }
                            ]
                        )
                    }

                    return .none
                case let .editProject(project):
                    state.createTimer = CreateFocusProjectReducer.State(
                        project: project,
                        isEditing: true
                    )
                    return .none
                }

            case .confirmationDialog:
                return .none

            case let .alert(.presented(.confirmDeleteProject(project))):
                state.alert = nil
                return deleteProject(project)

            case let .alert(.presented(.presentConfirmDeleteSingleProject(project))):
                state.alert = nil
                return deleteProject(project)

            case let .alert(.presented(.presentConfirmDeleteFollowingProjects(project))):
                state.alert = nil
                return deleteProject(project).concatenate(with: .run { _ in
                    if let recurrence = project.recurrence {
                        try await focusProjectClient.deleteRecurrence(recurrence)
                    }
                })

            case let .alert(.presented(.presentConfirmDeleteAllProjects(project))):
                state.alert = nil
                return deleteProject(project).concatenate(with: .run { _ in
                    if let recurrence = project.recurrence {
                        try await focusProjectClient.deleteAllRecurringProjectInstances(recurrence)
                    }
                })

            case .alert, .path, .activeFocusProject, .paywall, .newOnboarding:
                return .none

            }
        }
        .ifLet(\.$createTimer, action: /Action.createTimer) {
            CreateFocusProjectReducer()
        }
        .ifLet(\.$newOnboarding, action: /Action.newOnboarding) {
            NewFeaturesOnboardingReducer()
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
        .ifLet(\.activeFocusProject, action: /Action.activeFocusProject) {
            FocusProjectReducer()
        }
        .ifLet(\.$alert, action: /Action.alert)
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .forEach(\State.path, action: /Action.path) {
          Path()
        }
    }

    // MARK: - Helper

    func handleSelectedRecurrenceTemplate(_ state: inout State, _ project: FocusProject) -> EffectTask<Action> {
        let activeProject = FocusProject(
            id: uuid(),
            title: project.title,
            creationDate: date(),
            scheduledDate: date(),
            emoji: project.emoji,
            themeColor: project.themeColor,
            list: project.list.newInstance(uuid: { return uuid() }),
            timer: project.timer.newInstance(uuid: { return uuid() }),
            isActive: true,
            recurrence: project.recurrenceTemplate,
            recurrenceTemplate: nil
        )

        state.selectedFocusProject = activeProject
        state.path.append(
            .timerHome(
                FocusProjectReducer.State(
                    project: activeProject,
                    timer: TimerReducer.State(
                        project: activeProject
                    ),
                    list: FocusListReducer.State(
                        project: activeProject
                    )
                )
            )
        )

        return .run { [focusProjectClient] _ in
            try await focusProjectClient.updateAllProjectsInactive()
            try await focusProjectClient.createProject(activeProject)
        }
    }

    func handleSelectedProject(_ state: inout State, _ project: FocusProject) -> EffectTask<Action> {
        let oldSelectedProject = state.selectedFocusProject
        var activeProject = project
        activeProject.isActive = true
        state.selectedFocusProject = activeProject
        state.path.append(
            .timerHome(
                FocusProjectReducer.State(
                    project: activeProject,
                    timer: TimerReducer.State(
                        project: activeProject
                    ),
                    list: FocusListReducer.State(
                        project: activeProject
                    )
                )
            )
        )

        return (oldSelectedProject == nil ? EffectTask.none : EffectTask.task { .activeFocusProject(.suspendBackgroundMode) })
        .concatenate(
            with: .run { [focusProjectClient, activeProject] _ in
                try await focusProjectClient.updateAllProjectsInactive()
                try await focusProjectClient.updateProject(activeProject)
            }
        )
    }

    func monitorScheduledProjects(on date: Date) -> EffectTask<Action> {
        focusProjectClient.monitorScheduledProjectsOnDate(date)
            .catchToEffect()
            .map { result -> Action in
                switch result {
                case let .success(projects):
                    return .loadedProjects(projects, for: date)
                case .failure:
                    fatalError()
                }
            }
            .receive(on: mainQueue)
            .eraseToEffect()
    }

    func monitorActiveProject() -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.monitor)
            .concatenate(
                with: focusProjectClient.monitorActiveProject()
                    .catchToEffect().map { result in
                        switch result {
                        case let .success(project):
                            return .setActiveProject(project)
                        default:
                            fatalError()
                        }
                    }
            ).cancellable(id: CancelID.monitor)
    }

    func monitorDidPurchasePlus() -> EffectTask<Action> {
        userClient.monitorUser()
            .catchToEffect()
            .map { result in
                switch result {
                case let .success(user):
                    print("================== did purchase plus emission \(user)")
                    return .setDidPurchasePlus(user.didPurchasePlus)
                case .failure:
                    fatalError()
                }
            }
    }

    func cancelNotifications() -> EffectTask<Action> {
        return .none
    }

    func deleteProject(_ project: FocusProject) -> EffectTask<Action> {
        .run { send in
            try await focusProjectClient.deleteProject(project)

            if project.timer.isRunning && project.timer.isStandard {
                await send(.activeFocusProject(.suspendBackgroundMode))
            }
        }
    }

    func syncPurchasesIfNeeded() -> EffectTask<Action> {
        return .none
    }
}
