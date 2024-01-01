import SwiftUI
import ComposableArchitecture

struct FocusListView: View {

    // MARK: - Properties

    let store: StoreOf<FocusListReducer>
    @StateObject var keyboardManager: KeyboardManager

    var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /FocusListReducer.State.standard,
                action: FocusListReducer.Action.standard,
                then: { store in
                    StandardListView(store: store, keyboardManager: keyboardManager)
                }
            )
            CaseLet(
                state: /FocusListReducer.State.session,
                action: FocusListReducer.Action.session,
                then: { store in
                    SessionListView(store: store, keyboardManager: keyboardManager)
                }
            )
        }
    }
}

struct FocusListView_Previews: PreviewProvider {
    static var previews: some View {
        FocusListView(
            store: Store(
                initialState: FocusListReducer.State(
                    project: .init()
                )!,
                reducer: FocusListReducer()
            ),
            keyboardManager: KeyboardManager()
        )
    }
}
