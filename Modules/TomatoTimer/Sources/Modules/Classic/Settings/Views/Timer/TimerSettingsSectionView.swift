import Foundation
import SwiftUI
import ComposableArchitecture

struct TimerSettingsSectionView: View {

    let store: StoreOf<ClassicSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Stepper(
                    value: viewStore.binding(
                        get: \.viewState.secondsInWorkSession,
                        send: ClassicSettingsReducer.Action.setWorkLength
                    ), in: 1...120) {
                        Text("Work Session")
                        Text("\(Int(viewStore.state.viewState.secondsInWorkSession))")

                    }.frame(minHeight: 44)

                Divider()

                Stepper(
                    value: viewStore.binding(
                        get: \.viewState.secondsInShortBreak,
                        send: ClassicSettingsReducer.Action.setShortBreakLength
                    ), in: 1...120) {
                        Text("Short Break")
                        Text(" \(Int(viewStore.state.viewState.secondsInShortBreak))")
                    }.frame(minHeight: 44)

                Divider()

                Stepper(
                    value: viewStore.binding(
                        get: \.viewState.secondsInLongBreak,
                        send: ClassicSettingsReducer.Action.setLongBreakLength
                    ), in: 1...120) {
                        Text("Long Break")
                        Text("\(Int(viewStore.state.viewState.secondsInLongBreak))")
                    }.frame(minHeight: 44)

                Divider()

                Stepper(
                    value: viewStore.binding(
                        get: \.viewState.numberOfSessions,
                        send: ClassicSettingsReducer.Action.setNumberOfSessions
                    ), in: 1...10) {
                        Text("# of Sessions")
                        Text("\(viewStore.state.viewState.numberOfSessions)")
                    }.frame(minHeight: 44)
            }
        }
    }
}

struct TimerSettingsSectionView_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section("timer settings") {
                TimerSettingsSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(timer: .init(), settings: .init()),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
        }
    }
}
