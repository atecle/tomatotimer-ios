import Foundation
import SwiftUI
import ComposableArchitecture

struct CurrentTaskView: View {

    let store: StoreOf<FocusProjectReducer>

    @Environment(\.colorScheme) var colorScheme
    @State var textInput = ""
    @StateObject var keyboardManager: KeyboardManager
    @State var isPressedDown = false
    var scale: Double { isPressedDown ? 0.98 : 1 }

    var body: some View {
        WithViewStore(store, observe: { $0.taskViewUIState }) { viewStore in
            switch viewStore.currentTaskUIState {
            case .empty(.noTask):
                AddTaskEmptyStateView {
                    viewStore.send(.addTaskEmptyStatePressed)
                }
                .onTapGestureShowKeyboard(
                    text: $textInput,
                    placeholder: "What are you working on?",
                    keyboardManager: keyboardManager,
                    onCommit: { text in
                        viewStore.send(.onCommitEmptyState(text))
                    }
                )
                .onAppear {
                    textInput = ""
                }
                .opacity(viewStore.taskViewOpacity)
                .animation(.linear(duration: 0.2), value: viewStore.taskViewOpacity)
            case .empty(.selectTask):
                SelectTaskEmptyStateView {
                    viewStore.send(.selectTaskEmptyStatePressed)
                }
                .onAppear {
                    textInput = ""
                }
                .opacity(viewStore.taskViewOpacity)
                .animation(.linear(duration: 0.2), value: viewStore.taskViewOpacity)
            case let .task(task):
                HStack {
                    ZStack {
                        Circle()
                            .strokeBorder(.blue, lineWidth: 2)
                            .frame(width: 25, height: 25)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 25, height: 25)
                            .scaleEffect(viewStore.taskViewCompletedButtonScale)
                            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: viewStore.taskViewCompletedButtonScale)

                    }
                    .onTapGesture {
                        viewStore.send(.taskViewCompleteButtonPressed(task))
                        HapticFeedbackGenerator.impactOccurred(.medium)
                    }

                    Text(task.title)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .bold()
                }
                .contentShape(Rectangle())
                .frame(height: 50)
                .frame(minWidth: 100)
                .padding()
                .background(UIColor.label.asColor)
                .cornerRadius(10)
                .shadow(radius: 5)
                .animation(
                    .linear(
                        duration: 0.065
                    ),
                    value: scale
                )
                .padding()
                .onAppear {
                    textInput = task.title
                }
                .onTapGestureShowKeyboardNonSim(
                    text: $textInput,
                    placeholder: "What are you working on?",
                    keyboardManager: keyboardManager,
                    onCommit: { text in
                        viewStore.send(.onCommitTaskView(text))
                    }
                )
                .opacity(viewStore.taskViewOpacity)
                .animation(.linear(duration: 0.2), value: viewStore.taskViewOpacity)
            }
        }
    }
}

private struct CircularCheckbox: View {
    var task: FocusListTask
    var onToggle: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.blue, lineWidth: 2)
                .frame(width: 25, height: 25)
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .isHidden(task.completed == false)

        }
        .onTapGesture {
            onToggle()
            HapticFeedbackGenerator.impactOccurred(.light)
        }
    }
}

// MARK: - Helper

struct TaskViewUIState: Equatable {
    var currentTaskUIState: CurrentTaskUIState
    var taskViewOpacity: CGFloat
    var taskViewCompletedButtonScale: CGFloat

    init(_ state: FocusProjectReducer.State) {
        self.currentTaskUIState = state.currentTaskUIState
        self.taskViewOpacity = state.taskViewOpacity
        self.taskViewCompletedButtonScale = state.taskViewCompletionButtonScale
    }
}

enum CurrentTaskUIState: Equatable {
    case empty(Empty)
    case task(FocusListTask)

    enum Empty: Equatable {
        case noTask
        case selectTask
    }
}

extension FocusProjectReducer.State {
    var currentTaskUIState: CurrentTaskUIState {
        if project.list.tasks.isEmpty || project.list.allComplete {
            return .empty(.noTask)
        } else if project.list.tasks.filter(\.inProgress).count == 0 {
            return .empty(.selectTask)
        } else if let currentTask {
            return .task(currentTask)
        } else {
            return .empty(.noTask)
        }
    }

    var taskViewUIState: TaskViewUIState {
        return TaskViewUIState(self)
    }
}
