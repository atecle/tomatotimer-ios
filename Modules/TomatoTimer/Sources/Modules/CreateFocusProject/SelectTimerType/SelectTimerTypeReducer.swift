import Foundation
import ComposableArchitecture

struct SelectTimerTypeReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case selectedTimerType(TimerType)
        case setDidPurchasePlus(Bool)

        case paywall(PresentationAction<PaywallReducer.Action>)
    }

    struct State: Equatable {
        var selectedType: TimerType = .standard
        var didPurchasePlus: Bool = false

        @PresentationState var paywall: PaywallReducer.State?
    }

    // MARK: - Properties

    @Dependency(\.userClient) var userClient

    // MARK: - Methods

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return monitor()

            case let .selectedTimerType(type):
                if type == .stopwatch && !state.didPurchasePlus {
                    state.paywall = .init(paywallReason: .stopwatchTimer)
                } else {
                    state.selectedType = type
                }
                return .none

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

            case .paywall:
                return .none
            }
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
    }

    func monitor() -> EffectTask<Action> {
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
