import SwiftUI
import ComposableArchitecture

struct SelectAutostartSectionView: View {

    // MARK: - Definitions

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("Autostart") {
                VStack {
                    Toggle(
                        "Autostart Work Session",
                        isOn: viewStore.binding(
                            get: \.project.timer.autostartWorkSession,
                            send: CreateFocusProjectReducer.Action.setAutostartWorkSession
                        )
                    )
                    Divider()
                    Toggle(
                        "Autostart Break Session",
                        isOn: viewStore.binding(
                            get: \.project.timer.autostartBreakSession,
                            send: CreateFocusProjectReducer.Action.setAutostartBreakSession
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Previews

struct SelectAutostartSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectAutostartSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
