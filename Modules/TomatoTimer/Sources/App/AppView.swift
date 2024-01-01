import SwiftUI
import ComposableArchitecture

struct AppView: View {
    // MARK: - Properties

    @Environment(\.colorScheme) var colorscheme
    let store: StoreOf<AppReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            viewStore.showNewApp
            ? AnyView(TomatoTimerAppView(store: store))
            : AnyView(ClassicAppView(store: store))
        }
        .environmentObject(WeekStore())
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppReducer.State(),
                reducer: AppReducer()
            )
        )
    }
}
