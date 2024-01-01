//
//  PaywallReducer.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/18/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct PaywallReducer: ReducerProtocol {

    enum Action: Equatable {
        case viewDidAppear
        case setProduct(InAppPurchaseProduct)
        case setLoading(Bool)
        case dismiss

        case purchaseButtonPressed
        case restorePurchases
        case didPurchasePlus
        case setAlertState(AlertState<Action.Alert>)

        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {}
    }

    struct State: Equatable {
        var paywallReason: PaywallReason = .default
        var product: InAppPurchaseProduct?
        var isLoading: Bool = false

        @PresentationState var alert: AlertState<Action.Alert>?
    }

    // MARK: - Properties

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.services) var services
    @Dependency(\.userClient) var userClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return .none

            case let .setProduct(product):
                state.product = product
                return .none

            case .purchaseButtonPressed:
                return .none
            case .didPurchasePlus:
                return .run { _ in
                    try await userClient.update { user in
                        user.didPurchasePlus = true
                    }
                }.concatenate(with: .fireAndForget {
                    await self.dismiss()
                })

            case .restorePurchases:
                return .none

            case let .setLoading(loading):
                state.isLoading = loading
                return .none

            case .dismiss:
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
}
