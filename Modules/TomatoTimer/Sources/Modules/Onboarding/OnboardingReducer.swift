import Foundation
import ComposableArchitecture

struct OnboardingReducer: ReducerProtocol {

    enum Action: Equatable {
        case viewDidAppear
        case nextButtonPressed
        case delegate(Delegate)

        enum Delegate: Equatable {
            case createFirstTimer
        }
    }

    struct State: Equatable {
        var onboardingStep: OnboardingStep = .intro

        enum OnboardingStep {
            case intro
            case useATimer
            case timerTypes
            case listTypes
            case buildHabits
            case createTimer

            var next: OnboardingStep {
                switch self {
                case .intro:
                    return .useATimer
                case .useATimer:
                    return .timerTypes
                case .timerTypes:
                    return .listTypes
                case .listTypes:
                    return .buildHabits
                case .buildHabits:
                    return .createTimer
                case .createTimer:
                    return .createTimer
                }
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .delegate:
            return .none

        case .viewDidAppear:
            //services.userDefaultsService.setValue(key: .presentedNewOnboarding, value: true)
            return .none

        case .nextButtonPressed:
            guard state.onboardingStep != .createTimer else {
                return .merge(
                    EffectTask(value: .delegate(.createFirstTimer)),
                    .fireAndForget { await self.dismiss() }
                )
            }
            state.onboardingStep = state.onboardingStep.next
            return .none
        }
    }
}
