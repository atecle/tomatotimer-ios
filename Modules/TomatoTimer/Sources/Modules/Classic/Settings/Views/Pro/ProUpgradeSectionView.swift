import SwiftUI
import ComposableArchitecture

struct ProUpgradeSectionView: View {

    let store: StoreOf<ClassicSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 10) {
                Button("🔓\tUnlock More Features") {
                    viewStore.send(.unlockMoreFeaturesButtonPressed)
                }
            }
        }
    }
}

struct ProUpgradeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("go pro") {
                ProUpgradeSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(
                            timer: TomatoTimer(),
                            settings: .init()
                        ),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
        }
    }
}
