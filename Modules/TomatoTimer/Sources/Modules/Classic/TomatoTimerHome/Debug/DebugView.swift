import SwiftUI
import ComposableArchitecture

struct DebugView: View {

    let store: StoreOf<DebugReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    VStack(alignment: .center) {
                        Text("\(viewStore.tomatoTimer.currentSession.description)")
                        Text("\(DateComponentsFormatter.formatted(viewStore.tomatoTimer.secondsLeftInCurrentSession))")
                        List {
                            Section("Scheduled Notifications") {
                                ForEach(viewStore.notifications) { item in
                                    Text("Title: \(item.title) || Rings in \(item.timeUntilRing)")
                                }
                            }
                        }
                    }
                }.onAppear {
                    viewStore.send(.viewDidAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("dismiss") {
                            viewStore.send(.dismissButtonPressed)
                        }
                    }
                }
            }
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView(
            store: Store(
                initialState: DebugReducer.State(),
                reducer: DebugReducer()
            )
        )
    }
}

struct TempLocalNotif: Equatable, Identifiable {
    let id = UUID()
    var interval: TimeInterval
    var creationDate: Date
    var title: String

    var timeUntilRing: String {
        return DateComponentsFormatter.formatted(
            creationDate.addingTimeInterval(interval).timeIntervalSince(.now)
        )
    }
}

struct DebugReducer: ReducerProtocol {

    enum Action: Equatable {
        case viewDidAppear
        case dismissButtonPressed
        case setTimer(TomatoTimer)
        case setNotifications([TempLocalNotif])
    }

    struct State: Equatable {
        var tomatoTimer: TomatoTimer = .init()
        var notifications: [TempLocalNotif] = []
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.services) var services

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .dismissButtonPressed:
            return .fireAndForget {
               await self.dismiss()
            }

        case let .setNotifications(notifications):
            state.notifications = notifications
            return .none

        case let .setTimer(timer):
            state.tomatoTimer = timer
            return .none

        case .viewDidAppear:
            return .merge(
                services.timerService.timer()
                .catchToEffect()
                .map {
                    switch $0 {
                    case let .success(timer):
                        return .setTimer(timer)
                    case .failure:
                        fatalError()
                    }
                },
                .run { send in
                    let notifications = (await UNUserNotificationCenter.current().pendingNotificationRequests())
                        .map {
                            TempLocalNotif(
                                interval: ($0.trigger as? UNTimeIntervalNotificationTrigger)!.timeInterval,
                                // swiftlint:disable:next force_cast
                                creationDate: $0.content.userInfo["creation_date"] as! Date,
                                title: $0.content.title
                            )}
                    await send(.setNotifications(notifications))
                }
            )
        }
    }
}
