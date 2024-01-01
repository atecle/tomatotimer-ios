//
//  AllActivityGoalsReducer.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/16/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct AllActivityGoalsReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setGoals([ActivityGoal])

        case archiveButtonPressed(ActivityGoal)
        case unarchiveButtonPressed(ActivityGoal)
        case deleteButtonPressed(ActivityGoal)

        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case archive(ActivityGoal)
            case unarchive(ActivityGoal)
            case delete(ActivityGoal)
        }
    }

    struct State: Equatable {
        var activityGoals: [ActivityGoal] = []

        var activeGoals: [ActivityGoal] { activityGoals.filter { $0.isArchived == false } }
        var archivedGoals: [ActivityGoal] { activityGoals.filter { $0.isArchived == true } }

        @PresentationState var alert: AlertState<Action.Alert>?
    }

    // MARK: - Properties

    @Dependency(\.activityGoalClient) var activityGoalClient

    // MARK: - Methods

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return activityGoalClient.monitorAll()
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

            case let .archiveButtonPressed(goal):
                state.alert = .init(
                    title: TextState("Archive \(goal.title)?"),
                    buttons: [
                        ButtonState(action: .archive(goal)) {
                            TextState("Archive")
                        },
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                    ]
                )
                return .none

            case let .unarchiveButtonPressed(goal):
                state.alert = .init(
                    title: TextState("Unarchive \(goal.title)?"),
                    buttons: [
                        ButtonState(action: .unarchive(goal)) {
                            TextState("Unarchive")
                        },
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                    ]
                )
                return .none

            case let .deleteButtonPressed(goal):
                state.alert = .init(
                    title: TextState("Delete \(goal.title)?"),
                    message: TextState("This will permanently delete all activity data."),
                    buttons: [
                        ButtonState(role: .destructive, action: .delete(goal)) {
                            TextState("Delete")
                        }
                    ]
                )
                return .none

            case var .alert(.presented(.archive(goal))):
                goal.isArchived = true
                return .run { [goal] _ in
                    try await activityGoalClient.update(goal)
                }

            case var .alert(.presented(.unarchive(goal))):
                goal.isArchived = false
                return .run { [goal] _ in
                    try await activityGoalClient.update(goal)
                }

            case let .alert(.presented(.delete(goal))):
                return .run { [goal] _ in
                    try await activityGoalClient.delete(goal)
                }

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
