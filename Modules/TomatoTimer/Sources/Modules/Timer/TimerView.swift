import SwiftUI
import ComposableArchitecture

struct TimerView: View {

    let store: StoreOf<TimerReducer>

    var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /TimerReducer.State.standard,
                action: TimerReducer.Action.standard,
                then: StandardTimerView.init(store:)
            )
            CaseLet(
                state: /TimerReducer.State.stopwatch,
                action: TimerReducer.Action.stopwatch,
                then: StopwatchTimerView.init(store:)
            )
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            store: Store(
                initialState: .previews,
                reducer: TimerReducer()
            )
        )
    }
}
