import SwiftUI
import ComposableArchitecture

struct AdditionalSettingsSectionView: View {

    @Environment(\.openURL) var openURL
    let store: StoreOf<ClassicSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button("❓\tHow It Works") {
                viewStore.send(.howToUseButtonPressed)
            }
            Button("⭐️\tReview") {
                viewStore.send(.reviewButtonPressed)
            }
            Button("📧\tContact") {
                viewStore.send(.contactButtonPressed)
            }
            Button("🐛\tReport a Bug") {
                viewStore.send(.contactButtonPressed)
            }
        }
    }

}

struct AdditionalSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("additional") {
                AdditionalSettingsSectionView(
                    store: Store(initialState: ClassicSettingsReducer.State(timer: .init(), settings: .init()), reducer: ClassicSettingsReducer())
                )
            }
        }

    }
}
