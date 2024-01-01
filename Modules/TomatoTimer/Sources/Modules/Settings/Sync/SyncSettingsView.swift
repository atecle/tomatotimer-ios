//
//  SyncSettingsView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/23/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct SyncSettingsView: View {

    let store: StoreOf<SyncSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section {
                    Toggle(
                        isOn: viewStore.binding(
                            get: \.shouldSync,
                            send: SyncSettingsReducer.Action.setShouldSync
                        )
                    ) {
                        ListRowView(
                            title: "Sync with iCloud",
                            icon: .icloudFill,
                            iconBackground: .blue,
                            showPlusFeature: !viewStore.didPurchasePlus
                        )
                    }

                } header: {

                } footer: {
                    // swiftlint:disable:next line_length
                    Text("Syncing data to iCloud will allow data to be shared between all your devices and allow data to be restored if you delete the app. Quit the app and restart after toggling for the changes to take effect. ")
                }
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$paywall,
                    action: SyncSettingsReducer.Action.paywall
                ),
                content: PaywallView.init(store:)
            )
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
        }
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView(
            store: Store(
                initialState: SyncSettingsReducer.State(),
                reducer: SyncSettingsReducer()
            )
        )
    }
}
