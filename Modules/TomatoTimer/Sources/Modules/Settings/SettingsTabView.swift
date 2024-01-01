import SwiftUI
import ComposableArchitecture

struct SettingsTabView: View {

    // MARK: - Properties

    let store: StoreOf<SettingsTabReducer>

    // MARK: Body

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    UnlockPlusSectionView()
                        .isHidden(viewStore.didPurchasePlus, remove: true)
                        .onTapGesture {
                            viewStore.send(.unlockPlusSectionPressed)
                        }
                    GeneralSettingsSectionView(store: store)
                    ClassicModeSectionView(store: store)
                    SupportSettingsSectionView(store: store)
                    OtherSettingsSectionView(store: store)
                }
                .navigationTitle("Settings")
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
        } destination: { state in
            switch state {
            case .iCloudSync:
                CaseLet(
                    state: /SettingsTabReducer.Path.State.iCloudSync,
                    action: SettingsTabReducer.Path.Action.iCloudSync,
                    then: SyncSettingsView.init(store:)
                )

            case .advanced:
                CaseLet(
                    state: /SettingsTabReducer.Path.State.advanced,
                    action: SettingsTabReducer.Path.Action.advanced,
                    then: AdvancedSettingsView.init(store:)
                )
            }
        }
        .fullScreenCover(
            store: self.store.scope(
                state: \.$paywall,
                action: SettingsTabReducer.Action.paywall
            ),
            content: PaywallView.init(store:)
        )
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView(
            store: Store(
                initialState: SettingsTabReducer.State(),
                reducer: SettingsTabReducer()
            )
        )
    }
}
