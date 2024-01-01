import SwiftUI
import ComposableArchitecture

struct ClassicModeSectionView: View {

    // MARK: - Properties

    let store: StoreOf<SettingsTabReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                ToggleSettingsRow(
                    text: "Classic Mode",
                    isOn: viewStore.binding(
                        get: \.classicMode,
                        send: { .setClassicMode($0) }
                    ),
                    icon: .iphone,
                    iconBackground: UIColor.appIndigo.asColor
                )
            } header: {
                Text("Classic Mode")
            } footer: {
                Text(
                """
                Classic Mode reverts the UI to the original, more minimal Tomato Timer experience. \
                Quit the app and restart for the changes to take effect.
                """
                )
            }
        }
    }
}

struct ClassicModeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ClassicModeSectionView(
                store: Store(
                    initialState: SettingsTabReducer.State(),
                    reducer: SettingsTabReducer()
                )
            )
        }
    }
}
