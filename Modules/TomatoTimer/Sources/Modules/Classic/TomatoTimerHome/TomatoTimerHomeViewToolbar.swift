import SwiftUI
import ComposableArchitecture

// swiftlint:disable line_length

struct TomatoTimerHomeViewToolbar: ViewModifier {

    let store: StoreOf<TomatoTimerHomeReducer>
    @State private var showTime: Bool = true

    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.settingsButtonPressed)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 34, height: 34)
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                        }

                    }
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("\(infoText(viewStore).0)")
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                                .bold()
                                .frame(width: 400)
                            Text("\(infoText(viewStore).1)")
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                                .bold()
                        }

                        .onTapGesture(perform: {
                            showTime.toggle()
                        })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewStore.send(.menuButtonPressed)
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(viewStore.settingsShared.themeColor.complementaryColor))
                        }
                        .confirmationDialog(
                            store: self.store.scope(
                                state: \.$confirmationDialog,
                                action: TomatoTimerHomeReducer.Action.confirmationDialog
                            )
                        )
                    }
                }
        }
    }

    func infoText(_ viewStore: ViewStoreOf<TomatoTimerHomeReducer>) -> (String, String) {
        showTime
        ? ("\(DateComponentsFormatter.formatted(viewStore.tomatoTimer.secondsLeftInCurrentSession))", "\(viewStore.tomatoTimer.completedSessionsCount + 1)/\(viewStore.tomatoTimer.sessionsCount)")
        : ("\(viewStore.tomatoTimer.currentSession.description)", "\(viewStore.tomatoTimer.completedSessionsCount + 1)/\(viewStore.tomatoTimer.sessionsCount)")
    }
}

struct TimerHomeRootViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BackgroundColorView(color: .purple) {
            }.modifier(
                TomatoTimerHomeViewToolbar(
                    store: Store(
                        initialState: TomatoTimerHomeReducer.State(),
                        reducer: TomatoTimerHomeReducer())
                )
            )

        }
    }
}
