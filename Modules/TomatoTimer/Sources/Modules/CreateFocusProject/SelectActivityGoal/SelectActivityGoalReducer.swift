import Foundation
import ComposableArchitecture

struct SelectActivityGoalReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case plusButtonPressed
        case selectActivityGoal(ActivityGoal)
        case setGoals([ActivityGoal])
        case create(PresentationAction<CreateActivityGoalReducer.Action>)
    }

    struct State: Equatable {
        var project: FocusProject
        var activityGoals: [ActivityGoal] = []
        var selectedActivityGoals: [ActivityGoal] = []

        @PresentationState var create: CreateActivityGoalReducer.State?
    }

    // MARK: - Properties

    @Dependency(\.activityGoalClient) var activityGoalClient

    // MARK: - Methods

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return activityGoalClient.monitor()
                    .catchToEffect().map { result in
                        switch result {
                        case let .success(goals):
                            return .setGoals(goals)
                        case .failure:
                            fatalError()
                        }
                    }

            case let .setGoals(goals):
                state.activityGoals = goals
                return .none

            case .plusButtonPressed:
                state.create = .init()
                return .none

            case let .selectActivityGoal(goal):
                state.project.activityGoals.contains(where: { $0.id == goal.id })
                ? state.project.activityGoals.removeAll(where: { $0.id == goal.id })
                : state.project.activityGoals.append(goal)
                return .none

            case .create:
                return .none
            }
        }
        .ifLet(\.$create, action: /Action.create) {
            CreateActivityGoalReducer()
        }
    }
}
