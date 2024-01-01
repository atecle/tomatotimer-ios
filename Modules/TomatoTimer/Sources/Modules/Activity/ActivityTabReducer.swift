import Foundation
import ComposableArchitecture

struct ActivityTabReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setDidPurchasePlus(Bool)
        case setActivityGoalStats([ActivityGoalStatistic])
        case setActivityTotals(ActivityTotals)
        case setWeeklyActivityTotals(WeeklyActivityTotals)

        case plusButtonPressed
        case menuButtonPressed(ActivityGoalStatistic)
        case viewMoreButtonPressed
        case activityGoalPressed(ActivityGoal)
        case activitySummaryPressed

        // Presentation
        case paywall(PresentationAction<PaywallReducer.Action>)
        case createActivityGoal(PresentationAction<CreateActivityGoalReducer.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case alert(PresentationAction<Alert>)

        enum ConfirmationDialog: Equatable {
            case edit(ActivityGoalStatistic)
            case presentConfirmArchive(ActivityGoalStatistic)
            case presentConfirmDelete(ActivityGoalStatistic)
        }

        enum Alert: Equatable {
            case archive(ActivityGoalStatistic)
            case delete(ActivityGoalStatistic)
        }
    }

    struct State: Equatable {
        var stats: [ActivityGoalStatistic] = []
        var totals: ActivityTotals = .init()
        var weeklyTotals: WeeklyActivityTotals = .init()
        var didPurchasePlus: Bool = false

        var path: StackState<Path.State> = .init()

        @PresentationState var paywall: PaywallReducer.State?
        @PresentationState var createActivityGoal: CreateActivityGoalReducer.State?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @PresentationState var alert: AlertState<Action.Alert>?
    }

    struct Path: ReducerProtocol {
        enum Action: Equatable {
            case allActivityGoals(AllActivityGoalsReducer.Action)
            case activityGoalDetail(ActivityGoalDetailReducer.Action)
            case activitySummaryDetail(ActivitySummaryDetailReducer.Action)
        }

        enum State: Equatable {
            case allActivityGoals(AllActivityGoalsReducer.State)
            case activityGoalDetail(ActivityGoalDetailReducer.State)
            case activitySummaryDetail(ActivitySummaryDetailReducer.State)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.allActivityGoals, action: /Action.allActivityGoals) {
                AllActivityGoalsReducer()
            }
            Scope(state: /State.activityGoalDetail, action: /Action.activityGoalDetail) {
                ActivityGoalDetailReducer()
            }
            Scope(state: /State.activitySummaryDetail, action: /Action.activitySummaryDetail) {
                ActivitySummaryDetailReducer()
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.date) var date
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.activityGoalClient) var activityGoalClient
    @Dependency(\.userClient) var userClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return monitor()

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

            case let .setActivityGoalStats(stats):
                state.stats = stats
                return .none

            case let .setActivityTotals(totals):
                state.totals = totals
                return .none

            case let .setWeeklyActivityTotals(totals):
                state.weeklyTotals = totals
                return .none

            case .plusButtonPressed:
                if !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.createActivityGoal = .init()
                return .none

            case let .menuButtonPressed(stat):
                state.confirmationDialog = .init(
                    title: TextState("What do you want to do?"),
                    buttons: [
                        ButtonState(action: .edit(stat)) {
                            TextState("Edit")
                        },
                        ButtonState(action: .presentConfirmArchive(stat)) {
                            TextState("Archive")
                        },
                        ButtonState(role: .destructive, action: .presentConfirmDelete(stat)) {
                            TextState("Delete")
                        }
                    ]
                )
                return .none

            case .viewMoreButtonPressed:
                if !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.path.append(
                    .allActivityGoals(
                        AllActivityGoalsReducer.State()
                    )
                )
                return .none

            case let .activityGoalPressed(goal):
                state.path.append(
                    .activityGoalDetail(
                        ActivityGoalDetailReducer.State(goal: goal)
                    )
                )
                return .none

            case .activitySummaryPressed:
                if !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.path.append(
                    .activitySummaryDetail(
                        ActivitySummaryDetailReducer.State()
                    )
                )
                return .none

            case let .confirmationDialog(.presented(.edit(stat))):
                state.confirmationDialog = nil
                state.createActivityGoal = .init(activityGoal: stat.activityGoal, isEditing: true)
                return .none

            case let .confirmationDialog(.presented(.presentConfirmArchive(stat))):
                state.confirmationDialog = nil
                state.alert = .init(
                    title: TextState("Archive \(stat.activityGoal.title)?"),
                    // swiftlint:disable:next line_length
                    message: TextState("This will hide this activity goal from the main Activity tab view, but you can still access it by tapping 'View all'."),
                    buttons: [
                        ButtonState(action: .archive(stat)) {
                            TextState("Archive")
                        },
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                    ]
                )
                return .none

            case let .confirmationDialog(.presented(.presentConfirmDelete(stat))):
                state.confirmationDialog = nil
                state.alert = .init(
                    title: TextState("Delete \(stat.activityGoal.title)?"),
                    message: TextState("This will permanently delete all activity data."),
                    buttons: [
                        ButtonState(role: .destructive, action: .delete(stat)) {
                            TextState("Delete")
                        }
                    ]
                )
                return .none

            case .confirmationDialog:
                return .none

            case let .alert(.presented(.archive(stat))):
                var stat = stat
                stat.activityGoal.isArchived = true
                return .run { [stat] _ in
                    try await activityGoalClient.update(stat.activityGoal)
                }

            case let .alert(.presented(.delete(stat))):
                return .run { _ in
                    try await activityGoalClient.delete(stat.activityGoal)
                }

            case .alert:
                return .none

            case .createActivityGoal(.presented(.delegate(.didSave))):
                return .none

            case .createActivityGoal:
                return .none

            case .path:
                return .none

            case .paywall:
                return .none
            }
        }
        .ifLet(\.$createActivityGoal, action: /Action.createActivityGoal) {
            CreateActivityGoalReducer()
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .ifLet(\.$alert, action: /Action.alert)
        .forEach(\State.path, action: /Action.path) {
            Path()
        }
    }

    func monitor() -> EffectTask<Action> {
        .merge(
            monitorActivityTotals(),
            monitorWeeklyActivityTotals(),
            monitorActivityGoals(),
            monitorDidPurchasePlus()
        )
    }

    func monitorActivityTotals() -> EffectTask<Action> {
        return focusProjectClient
            .monitorActivityTotals()
            .catchToEffect().map { result in
                switch result {
                case let .success(totals):
                    return .setActivityTotals(totals)
                case .failure:
                    fatalError()
                }
            }
    }

    func monitorWeeklyActivityTotals() -> EffectTask<Action> {
        return focusProjectClient
            .monitorWeeklyActivityTotals(date())
            .catchToEffect().map { result in
                switch result {
                case let .success(totals):
                    return .setWeeklyActivityTotals(totals)
                case .failure:
                    fatalError()
                }
            }
    }

    func monitorActivityGoals() -> EffectTask<Action> {
        return activityGoalClient.monitorActivityGoalStatsForDateRange(
            (date().startOfWeek, date().endOfWeek)
        )
        .catchToEffect().map { result in
            switch result {
            case let .success(stats):
                return .setActivityGoalStats(stats)
            case .failure:
                fatalError()
            }
        }
    }

    func monitorDidPurchasePlus() -> EffectTask<Action> {
        userClient.monitorUser()
            .catchToEffect()
            .map { result in
                switch result {
                case let .success(user):
                    return .setDidPurchasePlus(user.didPurchasePlus)
                case .failure:
                    fatalError()
                }
            }
    }
}
