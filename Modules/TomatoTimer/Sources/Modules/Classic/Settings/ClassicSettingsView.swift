import SwiftUI
import ComposableArchitecture
import UIColorHexSwift

struct ClassicSettingsView: View {

    // MARK: - Definitions

    struct ViewState {
        let secondsInWorkSession: Int
        let secondsInShortBreak: Int
        let secondsInLongBreak: Int
        let numberOfSessions: Int
    }

    // MARK: - Properties

    let store: StoreOf<ClassicSettingsReducer>
    @State var footerTextStringIndex = 0

    // MARK: Methods

    init(store: StoreOf<ClassicSettingsReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        TimerSettingsSectionView(store: store)
                    } header: {
                        Text("timer settings")
                    } footer: {
                        Text("Adjusting these settings will reset the timer")
                    }

                    Section("theme color") {
                        ThemeColorSettingsSectionView(store: store)
                    }

                    Section("notification sound") {
                        NotificationSoundSectionView(store: store)
                    }

                    Section("other") {
                        AutostartSettingsSectionView(store: store)
                    }

                    if !viewStore.settings.purchasedPro {
                        Section("Upgrade") {
                            ProUpgradeSectionView(
                                store: store
                            )
                        }
                    }

                    Section {
                        Toggle(
                            "Classic Mode",
                            isOn: viewStore.binding(
                                get: \.classicMode,
                                send: ClassicSettingsReducer.Action.setClassicMode
                            )
                        )
                    } header: {
                        Text("Classic Mode")
                    } footer: {
                        // swiftlint:disable:next line_length
                        Text("You're using the original, more minimal Tomato Timer experience. Toggle Classic Mode off and restart the app to use additional features.")
                    }

                    Section {
                        AdditionalSettingsSectionView(
                            store: store
                        )
                    } header: {
                        Text("additional")
                    } footer: {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Text("\(String.footerTextStrings[footerTextStringIndex])")
                                    .onTapGesture {
                                        footerTextStringIndex = (footerTextStringIndex + 1) % 10
                                    }
                                Spacer()
                                Spacer()
                                Text("\(String.appVersion)")
                                    .multilineTextAlignment(.center)
                            }.multilineTextAlignment(.center)
                            Spacer()
                        }
                    }

                }
                .listStyle(.insetGrouped)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.dismissButtonPressed) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(UIColor.label.asColor)
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$proUpgrade,
                    action: ClassicSettingsReducer.Action.proUpgrade
                ),
                content: ProUpgradeView.init(store:)
            )
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$onboarding,
                    action: ClassicSettingsReducer.Action.onboarding
                ),
                content: ClassicOnboardingView.init(store:)
            )
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicSettingsView(
            store: Store(
                initialState: ClassicSettingsReducer.State(timer: .init(), settings: .init()),
                reducer: ClassicSettingsReducer()
            )
        )
    }
}

// MARK: - Helper

extension ClassicSettingsReducer.State {
    var viewState: ClassicSettingsView.ViewState {
        ClassicSettingsView.ViewState(
            secondsInWorkSession: settings.timerConfig.totalSecondsInWorkSession / 60,
            secondsInShortBreak: settings.timerConfig.totalSecondsInShortBreakSession / 60,
            secondsInLongBreak: settings.timerConfig.totalSecondsInLongBreakSession / 60,
            numberOfSessions: settings.timerConfig.numberOfTimerSessions
        )
    }
}
