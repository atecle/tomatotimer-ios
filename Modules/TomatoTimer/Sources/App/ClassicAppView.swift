import SwiftUI
import ComposableArchitecture

struct ClassicAppView: View {

    // MARK: - Properties

    let store: StoreOf<AppReducer>

    var body: some View {
        TomatoTimerHomeView(
            store: store.scope(
                state: \.classicHome,
                action: AppReducer.Action.classicHome
            )
        )
        .fullScreenCover(
            store: self.store.scope(
                state: \.$classicOnboarding,
                action: AppReducer.Action.classicOnboarding
            ),
            content: ClassicOnboardingView.init(store:)
        )
    }
}

struct ClassicAppView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicAppView(
            store: Store(
                initialState: AppReducer.State(),
                reducer: AppReducer()
            )
        )
    }
}
