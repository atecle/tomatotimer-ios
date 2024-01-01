import SwiftUI
import ComposableArchitecture

struct TomatoTimerAppView: View {

    let store: StoreOf<AppReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.tab, send: { .setTab($0) })) {

                // MARK: Focus

                FocusTabView(
                    store: store.scope(
                        state: \.focusTab,
                        action: AppReducer.Action.focusTab
                    )
                )
                .tabItem {
                    Label("Timer", systemSymbol: .clockFill)
                }
                .tag(AppReducer.Tab.focus)

                // MARK: Activity

                ActivityTabView(
                    store: store.scope(
                        state: \.activityTab,
                        action: AppReducer.Action.activityTab
                    )
                )
                .tabItem {
                    Label("Activity", systemSymbol: .chartBarFill)
                }
                .tag(AppReducer.Tab.activity)

                // MARK: Settings

                SettingsTabView(
                    store: store.scope(
                        state: \.settingsTab,
                        action: AppReducer.Action.settingsTab
                    )
                )
                .tabItem {
                    Label("Settings", systemSymbol: .gearshape2Fill)
                }
                .tag(AppReducer.Tab.user)
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$onboarding,
                    action: AppReducer.Action.onboarding
                ),
                content: OnboardingView.init(store:)
            )
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$classicOnboarding,
                    action: AppReducer.Action.classicOnboarding
                ),
                content: ClassicOnboardingView.init(store:)
            )
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$paywall,
                    action: AppReducer.Action.paywall
                ),
                content: PaywallView.init(store:)
            )
        }
    }
}

// MARK: - Previews

struct TomatoTimerAppView_Previews: PreviewProvider {
    static var previews: some View {
        TomatoTimerAppView(
            store: Store(
                initialState: AppReducer.State(),
                reducer: AppReducer()
            )
        )
        .environmentObject(WeekStore())
    }
}
