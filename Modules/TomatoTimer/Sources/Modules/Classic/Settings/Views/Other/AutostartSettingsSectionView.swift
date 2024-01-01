import SwiftUI
import ComposableArchitecture

struct AutostartSettingsSectionView: View {

    let store: StoreOf<ClassicSettingsReducer>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.settings.purchasedPro {
                    Toggle(
                        "Autostart Work Session",
                        isOn: viewStore.binding(
                            get: \.settings.timerConfig.shouldAutostartNextWorkSession,
                            send: ClassicSettingsReducer.Action.setAutostartNextWorkSession
                        )
                    )
                    Divider()
                    Toggle(
                        "Autostart Break Session",
                        isOn: viewStore.binding(
                            get: \.settings.timerConfig.shouldAutostartNextBreakSession,
                            send: ClassicSettingsReducer.Action.setAutostartNextBreakSession
                        )
                    )
                } else {
                    Toggle(
                        "Autostart Next Session",
                        isOn: viewStore.binding(
                            get: \.settings.timerConfig.shouldAutostartNextWorkSession,
                            send: ClassicSettingsReducer.Action.setAutostartNextSession
                        )
                    )
                }
                Divider()
                Toggle(
                    "Keep Screen Awake",
                    isOn: viewStore.binding(
                        get: \.settings.keepDeviceAwake,
                        send: ClassicSettingsReducer.Action.setKeepDeviceAwake
                    )
                )
                if viewStore.settings.purchasedPro {
                    Divider()
                    Toggle(
                        "Use To-Do List",
                        isOn: viewStore.binding(
                            get: \.settings.usingTodoList,
                            send: ClassicSettingsReducer.Action.setUseTodoList
                        )
                    )
                }
            }
        }
    }
}

struct AutostartSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("other") {
                AutostartSettingsSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(timer: .init(), settings: .init()),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
            Section("other pro") {
                AutostartSettingsSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(
                            timer: .init(),
                            settings: Settings(purchasedPro: true)
                        ),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
        }
    }
}
