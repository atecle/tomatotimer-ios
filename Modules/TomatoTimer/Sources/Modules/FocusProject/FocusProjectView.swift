import SwiftUI
import ComposableArchitecture

struct FocusProjectView: View {

    // MARK: - Properties

    @StateObject var keyboardManager = KeyboardManager()
    let store: StoreOf<FocusProjectReducer>

    // MARK: - Methods

    init(store: StoreOf<FocusProjectReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                switch viewStore.project.list {
                case .none:
                    if viewStore.project.timer.isComplete {
                        FocusProjectCompletedView(project: viewStore.project, resumeProjectAction: {
                            viewStore.send(.resumeProjectButtonPressed)
                        })
                    } else {
                        TimerView(
                            store: store.scope(
                                state: \.timer,
                                action: FocusProjectReducer.Action.timer
                            )
                        )
                    }

                case .singleTask:
                    VStack {
                        if viewStore.project.timer.isComplete {
                            FocusProjectCompletedView(project: viewStore.project, resumeProjectAction: {
                                viewStore.send(.resumeProjectButtonPressed)
                            })
                        } else {
                            Spacer()
                            CurrentTaskView(store: store, keyboardManager: keyboardManager)

                            TimerView(
                                store: store.scope(
                                    state: \.timer,
                                    action: FocusProjectReducer.Action.timer
                                )
                            )
                            Spacer()
                        }
                    }
                    .ignoresSafeArea(.keyboard)
                default:
                    TabView(
                        selection: viewStore.binding(
                            get: \.segmentedControlSelection,
                            send: { .segmentedControlSelectionChanged($0) }
                        )
                    ) {
                        if viewStore.project.timer.isComplete {
                            FocusProjectCompletedView(project: viewStore.project, resumeProjectAction: {
                                viewStore.send(.resumeProjectButtonPressed)
                            })
                            .tag(FocusProjectReducer.State.SegmentedControl.timer)
                        } else {
                            VStack {
                                CurrentTaskView(store: store, keyboardManager: keyboardManager)

                                TimerView(
                                    store: store.scope(
                                        state: \.timer,
                                        action: FocusProjectReducer.Action.timer
                                    )
                                )
                            }
                            .tag(FocusProjectReducer.State.SegmentedControl.timer)
                        }

                        IfLetStore(
                            store.scope(state: \.list, action: FocusProjectReducer.Action.list),
                            then: { store in
                                FocusListView(store: store, keyboardManager: keyboardManager)
                            }
                        )
                        .tag(FocusProjectReducer.State.SegmentedControl.list)
                        .opacity(viewStore.project.timer.isComplete ? 0.5 : 1)
                        .disabled(viewStore.project.timer.isComplete)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea(.keyboard)
                }
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$debug,
                    action: FocusProjectReducer.Action.debug
                ),
                content: DebugView.init(store:)
            )
            .toolbar {

                // We don't show the picker if we're in single task/none list mode
                if viewStore.project.list.shouldShowPicker {
                    ToolbarItem(placement: .principal) {
                        Picker(
                            "",
                            selection: viewStore.binding(
                                get: \.segmentedControlSelection,
                                send: { .segmentedControlSelectionChanged($0) }
                            )
                        ) {
                            Text("Timer").tag(FocusProjectReducer.State.SegmentedControl.timer)
                            Text("List").tag(FocusProjectReducer.State.SegmentedControl.list)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                switch viewStore.segmentedControlSelection {
                case .timer:
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.timerMenuButtonPressed) }) {
                            Image(
                                systemName: "ellipsis"
                            )
                            .foregroundColor(Color(UIColor.label))
                        }
                        .confirmationDialog(
                            store: self.store.scope(
                                state: \.$confirmationDialog,
                                action: FocusProjectReducer.Action.confirmationDialog
                            )
                        )
                        .opacity(viewStore.project.timer.isComplete || viewStore.project.list.incompleteTaskCount == 0 ? 0.5 : 1)
                        .disabled(viewStore.project.timer.isComplete || viewStore.project.list.incompleteTaskCount == 0)
                    }
                case .list:
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.listPlusButtonPressed) }) {
                            Image(
                                systemName: "plus"
                            )
                            .foregroundColor(Color(UIColor.label))
                        }
                        .onTapGestureShowKeyboard(
                            text: .constant(""),
                            placeholder: "Placeholder",
                            keyboardManager: keyboardManager,
                            onCommit: {
                                viewStore.send(.onCommitPlusButton($0))
                            }
                        )
                        .opacity(viewStore.project.timer.isComplete ? 0.5 : 1)
                        .disabled(viewStore.project.timer.isComplete)
                    }
                }

            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .navigationTitle(viewStore.project.title)
            .navigationBarTitleDisplayMode(.inline)
            .withKeyboardManager(keyboardManager: keyboardManager)
        }
    }
}

struct FocusProjectView_Previews: PreviewProvider {
    static var previews: some View {
        FocusProjectView(
            store: Store(
                initialState: FocusProjectReducer.State(
                    project: .stopwatchTimerStandardListPreview,
                    timer: .previews,
                    list: FocusListReducer.State(
                        project: .stopwatchTimerStandardListPreview
                    )!
                ),
                reducer: FocusProjectReducer()
            )
        )
    }
}

private extension FocusList {
    var shouldShowPicker: Bool {
        switch self {
        case .session, .standard: return true
        default: return false
        }
    }
}
