//
//  CreateActivityGoalReducer.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/15/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct CreateActivityGoalReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case dismissButtonPressed
        case doneButtonPressed

        case setTitle(String)
        case setTarget(TimeInterval)
        case setDaily
        case setWeekly
        case setSaving(Bool)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case didSave
        }
    }

    struct State: Equatable {
        let placeholder: String = activityGoalPlaceholders.randomElement()!
        var activityGoal: ActivityGoal = .init()
        var isEditing: Bool = false
        var isSaving: Bool = false

        var canSave: Bool { !activityGoal.title.isEmpty }

        init(activityGoal: ActivityGoal = .init(), isEditing: Bool = false) {
            self.activityGoal = activityGoal
            self.isEditing = isEditing
            self.isSaving = false
        }
    }

    // MARK: - Properties

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.activityGoalClient) var activityGoalClient

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .dismissButtonPressed:
            return .fireAndForget {
                await self.dismiss()
            }

        case let .setTitle(title):
            state.activityGoal.title = title
            return .none

        case .doneButtonPressed:
            return EffectTask(value: .setSaving(true))
                .concatenate(
                    with: .run { [state] send in
                        if state.isEditing {
                            try await activityGoalClient.update(state.activityGoal)
                        } else {
                            try await activityGoalClient.create(state.activityGoal)
                        }
                        await send(.delegate(.didSave))
                    }
                )
                .concatenate(
                    with: .fireAndForget {
                        await self.dismiss()
                    }
                )

        case let .setSaving(saving):
            state.isSaving = saving
            return .none

        case let .setTarget(target):
            state.activityGoal.goalSeconds = target * 60
            return .none

        case .setDaily:
            state.activityGoal.goalIntervalType = .daily
            return .none

        case .setWeekly:
            state.activityGoal.goalIntervalType = .weekly
            return .none

        case .delegate:
            return .none

        }
    }
}
