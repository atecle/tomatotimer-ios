import SwiftUI
import ComposableArchitecture

struct SessionListView: View {

    // MARK: - Properties

    @Environment(\.colorScheme) var colorScheme
    @StateObject var keyboardManager: KeyboardManager
    let store: StoreOf<SessionListReducer>

    // MARK: - Methods

    init(
        store: StoreOf<SessionListReducer>,
        keyboardManager: KeyboardManager
    ) {
        self.store = store
        self._keyboardManager = StateObject(wrappedValue: keyboardManager)
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(Array(viewStore.list.tasks.enumerated()), id: \.element) { (index, task) in
                    Section("Session \(index + 1)") {
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
                            .isHidden(viewStore.list.tasks.count == 1, remove: true)
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
                }
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .listStyle(.plain)
            .buttonStyle(PlainButtonStyle())
            .animation(.linear(duration: 0.2), value: UUID())
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: SessionListReducer.Action.alert
                )
            )
            .confirmationDialog(
                store: self.store.scope(
                    state: \.$confirmationDialog,
                    action: SessionListReducer.Action.confirmationDialog
                )
            )
        }
    }
}

struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListView(
            store: Store(
                initialState: SessionListReducer.State(
                    list: .init(tasks: FocusListTask.previews),
                    project: .init()
                ),
                reducer: SessionListReducer()
            ),
            keyboardManager: KeyboardManager()
        )
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
