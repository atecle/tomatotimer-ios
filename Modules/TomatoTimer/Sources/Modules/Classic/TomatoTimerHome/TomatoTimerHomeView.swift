import SwiftUI
import ComposableArchitecture
import SwiftUINavigation
import UserNotifications

// swiftlint:disable line_length

extension TomatoTimerHomeReducer.State {
    var toViewState: TomatoTimerHomeView.ViewState {
        return .init(themeColor: settingsShared.themeColor)
    }
}

struct TomatoTimerHomeView: View {

    // MARK: - Definitions

    struct ViewState: Equatable {
        var themeColor: UIColor
    }

    // MARK: - Properties

    let store: StoreOf<TomatoTimerHomeReducer>
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @SwiftUI.Environment(\.verticalSizeClass) var verticalSizeClass

    // MARK: View

    var body: some View {
        WithViewStore(
            store,
            observe: { $0.toViewState }
        ) { viewStore in
            NavigationStack {

                // MARK: - Main view

                BackgroundColorView(
                    color: viewStore.themeColor
                ) {
                    switch (horizontalSizeClass, verticalSizeClass) {
                    case (_, .some(.compact)):
                        LandscapeTimerHomeRootView(store: store)
                    default:
                        DefaultTimerHomeRootView(store: store)
                    }
                }
            }

            // MARK: - Transitions

            .fullScreenCover(
                store: self.store.scope(
                    state: \.$settings,
                    action: TomatoTimerHomeReducer.Action.settings
                ),
                content: ClassicSettingsView.init(store:)
            )
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$taskInput,
                    action: TomatoTimerHomeReducer.Action.taskInput
                ),
                content: TaskInputView.init(store:)
            )
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$planner,
                    action: TomatoTimerHomeReducer.Action.planner
                ),
                content: PlannerHomeView.init(store:)
            )

            // MARK: - View Lifecycle

            .onAppear {
                viewStore.send(.viewDidAppear)
            }
        }
    }
}

// MARK: Previews

struct TimerHomeRootView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SupportedDevice.allCases, id: \.self) { device in
            TomatoTimerHomeView(
                store: Store(
                    initialState: TomatoTimerHomeReducer.State(),
                    reducer: TomatoTimerHomeReducer()
                )
            )
            .previewDevice(PreviewDevice(rawValue: device.rawValue))
            .previewDisplayName(device.rawValue)
        }
    }
}

// MARK: Orientation Views

struct DefaultTimerHomeRootView: View {

    let store: StoreOf<TomatoTimerHomeReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                FocusTaskView(
                    store: store
                )
                TomatoTimerView(
                    store: store.scope(
                        state: \.timer,
                        action: TomatoTimerHomeReducer.Action.timer
                    )
                )
                Button("Enable Notifications to use timer") {
                    // Create the URL that deep links to your app's notification settings.
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        // Ask the system to open that URL.
                        UIApplication.shared.open(url)
                    }

                }
                .isHidden(viewStore.timer.authorizedNotifications, remove: true)
                .foregroundColor(
                    viewStore.settingsShared.themeColor.complementaryColor.asColor
                )
                .bold()
                .padding()
                .background(.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
                Spacer()
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$debug,
                    action: TomatoTimerHomeReducer.Action.debug
                ),
                content: DebugView.init(store:)
            )
            .modifier(
                TomatoTimerHomeViewToolbar(
                    store: store
                )
            )
        }
    }
}

struct LandscapeTimerHomeRootView: View {

    let store: StoreOf<TomatoTimerHomeReducer>
    @State private var showTime: Bool = true

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("\(infoText(viewStore).0)")
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                                .multilineTextAlignment(.leading)
                            Text("\(infoText(viewStore).1)")
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.top)
                        .onTapGesture {
                            showTime.toggle()
                        }
                        Spacer()
                        Button {
                            viewStore.send(.settingsButtonPressed)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 34, height: 34)
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                        }

                    }
                    Spacer()
                }

                Spacer()
                TomatoTimerView(
                    store: store.scope(
                        state: \.timer,
                        action: TomatoTimerHomeReducer.Action.timer
                    )
                )
                Spacer()
            }
        }
    }

    func infoText(_ viewStore: ViewStoreOf<TomatoTimerHomeReducer>) -> (String, String) {
        showTime
        ? ("\(DateComponentsFormatter.formatted(viewStore.tomatoTimer.secondsLeftInCurrentSession))", "\(viewStore.tomatoTimer.completedSessionsCount + 1)/\(viewStore.tomatoTimer.sessionsCount)")
        : ("\(viewStore.tomatoTimer.currentSession.description)", "\(viewStore.tomatoTimer.completedSessionsCount + 1)/\(viewStore.tomatoTimer.sessionsCount)")
    }
}

extension TomatoTimerHomeReducer.State {
    var focusTaskViewState: FocusTaskView.ViewState {
        return .init(
            isUsingToDoList: settingsShared.usingTodoList,
            task: currentProjectShared.currentTask?.toUITask,
            taskCompleted: taskCompleted,
            taskOpacity: taskOpacity,
            themeColor: settingsShared.themeColor.asColor
        )
    }
}

private extension TodoListTask {
    var toUITask: FocusTaskView.ViewState.UITask {
        .init(title: title)
    }
}
