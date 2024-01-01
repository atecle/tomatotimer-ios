import Foundation
import ComposableArchitecture

struct ProUpgradeReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case onAppear
        case setLoading(Bool)
        case setPrice(String)
        case purchasePro
        case didPurchasePro
        case restorePurchases
        case dismissButtonPressed
        case setAlertState(AlertState<Alert>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case purchasedPro(Settings)
        }

        enum Alert: Equatable {}
    }

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var price: String = ""
        var settings: Settings
        var isLoading: Bool = false
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .onAppear:

                return .run { send in
                    await send(.setPrice(""))
                }

            case let .setPrice(price):
                state.price = price
                return .none

            case .purchasePro:
                return .none

            case .didPurchasePro:
                return .none

            case .restorePurchases:
                return .none

            case let .setLoading(loading):
                state.isLoading = loading
                return .none

            case .dismissButtonPressed:
                return .fireAndForget {
                    await self.dismiss()
                }

            case let .setAlertState(alert):
                state.alert = alert
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }

    func saveSettingsToDisk(_ settings: Settings) -> EffectTask<Action> {
        return .run { _ in
            try await services.settingsService.update(settings)
        }
    }
}
