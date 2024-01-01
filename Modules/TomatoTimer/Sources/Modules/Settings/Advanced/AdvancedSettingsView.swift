//
//  AdvancedSettingsView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/23/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct AdvancedSettingsView: View {

    let store: StoreOf<AdvancedSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section {
                    ListRowView(
                        title: "Reset App",
                        titleColor: UIColor.appPomodoroRed.asColor,
                        icon: .trashFill,
                        iconBackground: UIColor.appPomodoroRed.asColor,
                        accessory: .none,
                        showPlusFeature: false,
                        bold: true
                    )
                } header: {

                } footer: {
                    Text("This will erase all data and settings for Tomato Timer on all devices. This is an irreversible action.")
                }
            }
            .onTapGesture {
                viewStore.send(.resetAppPressed)
            }
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: AdvancedSettingsReducer.Action.alert
                )
            )
            .navigationTitle("Advanced")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView(
            store: Store(
                initialState: AdvancedSettingsReducer.State(),
                reducer: AdvancedSettingsReducer()
            )
        )
    }
}
