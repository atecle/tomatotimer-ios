import SwiftUI
import ComposableArchitecture

struct StandardTimerView: View {

    // MARK: - Properties

    let store: StoreOf<StandardTimerReducer>
    @Environment(\.colorScheme) var colorScheme
    @State var showTime: Bool = true

    // MARK: - Methods

    init(store: StoreOf<StandardTimerReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                StandardTimerControlView(
                    viewState: viewStore.state.controlViewState,
                    animationCompletion: {
                        viewStore.send(.setAnimation(nil))
                    }
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .padding([.leading, .trailing, .top], 32)
                .padding([.bottom], 16)
                .frame(maxWidth: 500)
                .contentShape(Circle())
                .onTapGestureSimultaneous {
                    guard viewStore.incompleteTaskCount > 0 else { return }
                    viewStore.send(.toggleIsRunning)
                }

                VStack {
                    Text("\(viewStore.timer.currentSession.description)")
                    Text(showTime ? "\(viewStore.timer.timeDisplayString)" : "\(viewStore.timer.sessionProgressDisplayString)")
                }
                .contentShape(Rectangle())
                .padding(8)
                .background(
                    viewStore.timer.displayColor
                )
                .cornerRadius(10)
                .shadow(radius: 4)
                .onTapGestureSimultaneous {
                    showTime.toggle()
                }
                .foregroundColor(viewStore.timer.isRunning ? .white : (
                    colorScheme == .dark ? .black : .white
                ))
                .bold()
            }
        }
    }
}

struct StandardTimerView_Previews: PreviewProvider {
    static var previews: some View {
        StandardTimerView(
            store: Store(
                initialState: StandardTimerReducer.State(
                    timer: .init(),
                    project: .init()
                ),
                reducer: StandardTimerReducer()
            )
        )
    }
}
