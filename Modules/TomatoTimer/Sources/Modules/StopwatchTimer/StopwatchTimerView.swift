import SwiftUI
import ComposableArchitecture

extension StopwatchTimerReducer.State {
    var viewState: StopwatchTimerView.ViewState {
        return .init(timer: timer, isDisabled: project.list.incompleteTaskCount == 0)
    }
}

struct StopwatchTimerView: View {

    struct ViewState: Equatable {
        var timer: StopwatchTimer
        var isDisabled: Bool
    }

    // MARK: - Properties

    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<StopwatchTimerReducer>

    // MARK: - Methods

    init(store: StoreOf<StopwatchTimerReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                StopwatchTimerControlView(
                    viewState: viewStore.viewState,
                    onTapGesture: {
                        guard !viewStore.viewState.isDisabled else { return }
                        viewStore.send(.toggleIsRunning)
                    }
                )
                .padding([.leading, .trailing, .top], 32)
                .padding([.bottom], 16)
                .frame(maxWidth: 500)
                .contentShape(Circle())
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }

                VStack {
                    Text("\(viewStore.timer.currentSession.description)")
                    Text("\(viewStore.timer.timeDisplayString)")
                }
                .contentShape(Rectangle())
                .padding(8)
                .background(
                    viewStore.timer.displayColor
                )
                .cornerRadius(10)
                .shadow(radius: 4)
                .onTapGestureSimultaneous {
                    guard !viewStore.viewState.isDisabled else { return }
                    print("========= toggling session")
                    HapticFeedbackGenerator.impactOccurred(.medium)
                    viewStore.send(.toggleSession)
                }
                .foregroundColor(viewStore.timer.isRunning ? .white : (
                    colorScheme == .dark ? .black : .white
                ))
                .bold()
                .opacity(viewStore.viewState.isDisabled ? 0.5 : 1)
            }

        }
    }

}

struct StopwatchTimerView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchTimerView(
            store: Store(
                initialState: StopwatchTimerReducer.State(
                    timer: .init(),
                    project: .init()
                ),
                reducer: StopwatchTimerReducer()
            )
        )
    }
}
