import Foundation
import SwiftUI
import ComposableArchitecture

struct StandardListView: View {

    // MARK: - Properties

    @Environment(\.colorScheme) var colorScheme
    @State var addTaskText = ""
    let store: StoreOf<StandardListReducer>
    @StateObject var keyboardManager: KeyboardManager

    // MARK: - Methods

    init(
        store: StoreOf<StandardListReducer>,
        keyboardManager: KeyboardManager
    ) {
        self.store = store
        self._keyboardManager = StateObject(wrappedValue: keyboardManager)
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.list.tasks) { task in
                    HStack {
                        CircularCheckbox(task: task) {
                            viewStore.send(.toggleCompleted(task))
                        }
                        Text("\(task.title)")
                            .foregroundColor(task.completed ? UIColor.label.asColor.opacity(0.5) : UIColor.label.asColor)
                        Spacer()
                        Text("In Progress")
                            .font(.caption)
                            .bold()
                            .padding(6)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .background(colorScheme == .dark ? .white : .black)
                            .cornerRadius(5)
                            .isHidden(!task.inProgress, remove: true)
                        Button(action: { viewStore.send(.listRowMenuButtonPressed(task)) }) {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(UIColor.label.asColor)
                        }
                        .confirmationDialog(
                            store: self.store.scope(
                                state: \.$confirmationDialog,
                                action: StandardListReducer.Action.confirmationDialog
                            )
                        )
                    }
                    .contentShape(Rectangle())
                    .onTapGestureShowKeyboardNonSim(
                        text: .constant(task.title),
                        placeholder: "Placeholder",
                        keyboardManager: keyboardManager,
                        onCommit: {
                            viewStore.send(.updateTitle(for: task, title: $0))
                        }
                    )
                }
                .onMove {
                    viewStore.send(.move(from: $0, to: $1))
                }
            }
            .onAppear {
                addTaskText = ""
                viewStore.send(.viewDidAppear)
            }
            .overlay(self.EmptyState(
                shouldShow: viewStore.list.tasks.isEmpty,
                onCommit: {
                    viewStore.send(.onCommitAddTaskEmptyState($0))
                })
            )
            .listStyle(.plain)
            .buttonStyle(PlainButtonStyle())
            .animation(.linear(duration: 0.2), value: UUID())
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: StandardListReducer.Action.alert
                )
            )
        }
    }

    func EmptyState(
        shouldShow: Bool,
        onTap: (() -> Void)? = nil,
        onCommit: @escaping (String) -> Void
    ) -> some View {
        Group {
            if shouldShow {
                AddTaskEmptyStateView(onTap: onTap ?? {})
                    .onTapGestureShowKeyboard(
                        text: $addTaskText,
                        placeholder: "What are you working on?",
                        keyboardManager: keyboardManager,
                        onCommit: onCommit
                    )
            }
        }
    }
}

// MARK: - Previews

struct StandardListView_Previews: PreviewProvider {
    static var previews: some View {
        StandardListView(
            store: Store(
                initialState: StandardListReducer.State(
                    list: .init(tasks: FocusListTask.previews),
                    project: .init()
                ),
                reducer: StandardListReducer()
            ),
            keyboardManager: KeyboardManager()
        )
    }
}

// MARK: Helper

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
