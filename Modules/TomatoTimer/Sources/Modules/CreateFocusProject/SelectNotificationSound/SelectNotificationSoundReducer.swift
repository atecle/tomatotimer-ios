import Foundation
import ComposableArchitecture

struct SelectNotificationSoundReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setDidPurchasePlus(Bool)
        case selectedSound(NotificationSound)

        case paywall(PresentationAction<PaywallReducer.Action>)
    }
    struct State: Equatable {
        var sound: NotificationSound = .bell
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

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

            case let .selectedSound(sound):
                if sound.isProSound && !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.sound = sound
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
