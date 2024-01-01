import Foundation
import SwiftUI
import ComposableArchitecture

struct FocusTaskView: View {

    // MARK: - Definitions

    struct ViewState: Equatable {
        let isUsingToDoList: Bool
        let task: UITask?
        let taskCompleted: Bool
        let taskOpacity: Double
        let themeColor: Color

        struct UITask: Equatable {
            let title: String
        }
    }

    // MARK: - Properties

    let store: StoreOf<TomatoTimerHomeReducer>
    @State var isPressedDown: Bool = false
    private var scale: CGFloat { isPressedDown ? 0.96 : 1 }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0.focusTaskViewState }) { viewStore in
            VStack {
                switch viewStore.task {
                case let .some(task):
                    HStack {
                        FocusTaskButton(
                            themeColor: viewStore.themeColor,
                            isOn: viewStore.taskCompleted
                        )
                            .gesture(TapGesture().onEnded {
                                viewStore.send(.markTaskCompleted)
                                HapticFeedbackGenerator.impactOccurred(.light)
                            })
                        Text(task.title)
                            .foregroundColor(viewStore.themeColor.asUIColor.isLight() ? .white : .black)
                    }
                    .padding()
                    .frame(height: 64)
                    .background(viewStore.themeColor.complementaryColor)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .scaleEffect(scale)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isPressedDown = true
                            }
                            .onEnded { _ in
                                isPressedDown = false
                                viewStore.send(.focusTaskButtonPressed)
                            }
                    )
                    .animation(
                        .linear(
                            duration: 0.065
                        ),
                        value: scale
                    )
                    .opacity(viewStore.taskOpacity)
                    .animation(.linear(duration: 0.1), value: viewStore.taskOpacity)
                    .padding([.top], 40)
                case .none:
                    Button("What are you working on?") {
                        viewStore.send(.focusTaskButtonPressed)
                    }
                    .frame(height: 64)
                    .padding([.top], 40)
                    .font(.title)
                    .foregroundColor(viewStore.themeColor.complementaryColor)
                    .bold()
                    .opacity(viewStore.taskOpacity)
                    .animation(.linear(duration: 0.1), value: viewStore.taskOpacity == 1 ? 0 : 1)
                }
            }
        }
    }
}

// MARK: - Preview

struct FocusTaskView_Previews: PreviewProvider {
    static var previews: some View {
        TomatoTimerHomeView(
            store: Store(
                initialState: TomatoTimerHomeReducer.State(),
                reducer: TomatoTimerHomeReducer()
            )
        )
    }
}

// MARK: Helper

struct FocusTaskButton: View {

    let themeColor: Color
    let isOn: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(themeColor.asUIColor.isLight() ? .white : .blue, lineWidth: 2.3)
                .frame(width: 25, height: 25)
            Circle()
                .fill(themeColor.asUIColor.isLight() ? .white : .blue)
                .frame(width: 16, height: 16)
                .isHidden(isOn == false)

        }
    }
}
