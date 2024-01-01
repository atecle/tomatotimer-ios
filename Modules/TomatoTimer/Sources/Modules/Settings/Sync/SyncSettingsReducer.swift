import Foundation
import ComposableArchitecture

struct SyncSettingsReducer: ReducerProtocol {

    enum Action: Equatable {
        case viewDidAppear
        case setShouldSync(Bool)
        case setDidPurchasePlus(Bool)

        case paywall(PresentationAction<PaywallReducer.Action>)
    }

    struct State: Equatable {
        var didPurchasePlus: Bool = false
        var shouldSync: Bool = false

        @PresentationState var paywall: PaywallReducer.State?
    }

    @Dependency(\.userClient) var userClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                state.shouldSync = NSUbiquitousKeyValueStore.default.bool(forKey: "icloud_sync")
                return userClient.monitorUser().catchToEffect().map { result in
                    switch result {
                    case let .success(user):
                        return .setDidPurchasePlus(user.didPurchasePlus)
                    case .failure:
                        fatalError()
                    }
                }

            case let.setDidPurchasePlus(plus):
                state.didPurchasePlus = plus
                return .none

            case let .setShouldSync(shouldSync):
                if !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.shouldSync = shouldSync
                NSUbiquitousKeyValueStore.default.set(shouldSync, forKey: "icloud_sync")
                return .none

            case .paywall:
                return .none
            }
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
    }
}
