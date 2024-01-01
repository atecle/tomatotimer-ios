//
//  AdvancedSettingsReducer.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/23/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import ComposableArchitecture
import CoreData

struct AdvancedSettingsReducer: ReducerProtocol {
    enum Action: Equatable {
        case resetAppPressed
        case alert(PresentationAction<Alert>)
        enum Alert {
            case confirmResetApp
        }
    }

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .resetAppPressed:
                state.alert = .init(
                    title: TextState("Reset all data?"),
                    // swiftlint:disable:next line_length
                    message: TextState("Are you sure you want to delete all projects, all activity data, and reset all settings? The app will force quit after deletion."),
                    buttons: [
                        ButtonState(role: .destructive, action: .confirmResetApp) {
                            TextState("Delete")
                        }
                    ]
                )
                return .none
            case .alert(.presented(.confirmResetApp)):

                return .run { _ in
                    try await CoreDataStack.live.clearDatabase()
//
//                    // Get a reference to a NSPersistentStoreCoordinator
//                    let storeContainer =
//                    CoreDataStack.live.container.persistentStoreCoordinator
//
//                    // Delete each existing persistent store
//                    for store in storeContainer.persistentStores {
//                        try storeContainer.destroyPersistentStore(
//                            at: store.url!,
//                            ofType: store.type,
//                            options: nil
//                        )
//                    }
//
//                    let domain = Bundle.main.bundleIdentifier!
//                    UserDefaults.standard.removePersistentDomain(forName: domain)
//                    UserDefaults.standard.synchronize()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                        exit(0)
                    }
                }

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
