import Foundation
import SwiftUI
import ComposableArchitecture

struct TimerConfigurationSectionView: View {

    struct ViewState {
        let secondsInWorkSession: Int
        let secondsInShortBreak: Int
        let secondsInLongBreak: Int
        let numberOfSessions: Int
    }

    let store: StoreOf<CreateFocusProjectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("Timer Configuration") {
                VStack {
                    Stepper(
                        value: viewStore.binding(
                            get: \.viewState.secondsInWorkSession,
                            send: CreateFocusProjectReducer.Action.setWorkLength
                        ), in: 1...120) {
                            Text("Work Session")
                            Text("\(Int(viewStore.state.workSessionLength / 60))")

                        }.frame(minHeight: 44)

                    Divider()

                    Stepper(
                        value: viewStore.binding(
                            get: \.viewState.secondsInShortBreak,
                            send: CreateFocusProjectReducer.Action.setShortBreakLength
                        ), in: 1...120) {
                            Text("Short Break")
                            Text(" \(Int(viewStore.state.shortBreakLength / 60))")
                        }.frame(minHeight: 44)

                    Divider()

                    Stepper(
                        value: viewStore.binding(
                            get: \.viewState.secondsInLongBreak,
                            send: CreateFocusProjectReducer.Action.setLongBreakLength
                        ), in: 1...120) {
                            Text("Long Break")
                            Text("\(Int(viewStore.state.longBreakLength / 60))")
                        }.frame(minHeight: 44)

                    Divider()

                    Stepper(
                        value: viewStore.binding(
                            get: \.viewState.numberOfSessions,
                            send: CreateFocusProjectReducer.Action.setNumberOfSessions
                        ), in: 1...10) {
                            Text("# of Sessions")
                            Text("\(viewStore.state.sessionCount)")
                        }.frame(minHeight: 44)
                }
            }
        }
    }
}

struct TimerConfigurationSectionView_Previews: PreviewProvider {

    static var previews: some View {
        List {
            TimerSettingsSectionView(
                store: Store(
                    initialState: ClassicSettingsReducer.State(timer: .init(), settings: .init()),
                    reducer: ClassicSettingsReducer()
                )
            )
        }
    }
}

extension CreateFocusProjectReducer.State {
    var viewState: TimerConfigurationSectionView.ViewState {
        TimerConfigurationSectionView.ViewState(
            secondsInWorkSession: workSessionLength / 60,
            secondsInShortBreak: shortBreakLength / 60,
            secondsInLongBreak: longBreakLength / 60,
            numberOfSessions: sessionCount
        )
    }
}
