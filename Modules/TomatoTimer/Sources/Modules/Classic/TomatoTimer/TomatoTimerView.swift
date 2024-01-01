import SwiftUI
import ComposableArchitecture

struct TomatoTimerView: View {

    let store: StoreOf<TomatoTimerReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TomatoTimerControlView(
                store: store
            )
            .padding(32)
            .frame(maxWidth: 500)
            .contentShape(Circle())
            .onTapGestureSimultaneous {
                viewStore.send(.toggleIsRunning)
            }
            .onAppear { viewStore.send(.viewDidAppear) }
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                viewStore.send(.checkNotificationStatus)
//            }
        }
    }
}

struct TomatoTimerView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColorView(color: .appPomodoroRed) {
            TomatoTimerView(
                store: Store(
                    initialState: TomatoTimerReducer.State(
                        tomatoTimer: .init(),
                        scheduledNotifications: .init(),
                        settings: .init()
                    ),
                    reducer: TomatoTimerReducer()
                )
            )
        }
    }
}
