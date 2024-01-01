import SwiftUI
import ComposableArchitecture
import SwiftUINavigation
import Combine

// swiftlint:disable identifier_name
struct PlannerHomeView: View {

    // MARK: - Properties

    @FocusState var focus: PlannerHomeReducer.PlannerListItem?
    let store: StoreOf<PlannerHomeReducer>

    init(store: StoreOf<PlannerHomeReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0.toUIState }) { viewStore in
            NavigationStack {

                // MARK: - Main List

                List {
                    ForEach(viewStore.tasks) { task in
                        PlannerListRow(
                            focus: $focus,
                            task: viewStore.binding(get: { _ in task }, send: { .editTask($0) }).removeDuplicates(),
                            onEditingChanged: {
                                viewStore.send(.isEditingChanged($0, item: task))
                            },
                            onSubmit: {
                                viewStore.send(.onSubmit(task))
                            }
                        )
                        .deleteDisabled(task.isNewTask)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button("In Progress") { viewStore.send(.setInProgressTask(task)) }
                                .isHidden(task.completed || task.isNewTask)
                        }
                    }
                    .onDelete { viewStore.send(.delete(at: $0)) }
                    .onMove { viewStore.send(.move(at: $0, to: $1)) }
                }
                .safeAreaInset(edge: .bottom, spacing: 16) {
                    // https://developer.apple.com/forums/thread/699111
                    // This is a weird hack to get more space between the keyboard and the last cell.
                    // The task input UI is a bit janky but no use spending more time on that now.
                    EmptyView().frame(height: 0)
                }
                .animation(.default, value: UUID())
                .navigationTitle(viewStore.projectTitle)
                .listStyle(.plain)
                .overlay(self.EmptyState(viewStore.emptyState))

                // MARK: - Transitions

                .alert(
                    "Change project title",
                    isPresented: viewStore.binding(
                        get: \.isRenameProjectAlertPresented,
                        send: { .setIsRenameProjectAlertPresented($0) }
                    )
                ) {
                    TextField(
                        "Rename project",
                        text: viewStore.binding(
                            get: \.renameProjectAlertTextInput,
                            send: { .setRenameProjectAlertTextInput($0) }
                        )
                    )
                    Button("Save") {
                        viewStore.send(.renameProject(viewStore.renameProjectAlertTextInput))
                    }
                }

                .fullScreenCover(
                    store: self.store.scope(
                        state: \.$projects,
                        action: PlannerHomeReducer.Action.projects
                    ),
                    content: ProjectsView.init(store:)
                )

                // MARK: - Toolbar

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            viewStore.send(.dismissButtonPressed)
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(UIColor.label.asColor)
                        }
                    }
                    if !viewStore.showEditingToolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewStore.send(.plusButtonPressed)
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(UIColor.label.asColor.opacity(viewStore.canAddMoreTasks ? 1 : 0.2))
                            }
                            .disabled(!viewStore.canAddMoreTasks)
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewStore.send(.menuButtonPressed)
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(UIColor.label.asColor)
                            }
                            .confirmationDialog(
                                store: self.store.scope(
                                    state: \.$confirmationDialog,
                                    action: PlannerHomeReducer.Action.confirmationDialog
                                )
                            )
                        }

                    }

                    if viewStore.showEditingToolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewStore.send(.doneButtonPressed)
                            }) {
                                Text("Done")
                                    .bold()
                                    .foregroundColor(UIColor.label.asColor)
                            }
                        }
                    }
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .bind(viewStore.binding(get: \.focus, send: { .setFocus($0) }), to: $focus)
        }
    }

    func EmptyState(_ emptyState: PlannerHomeReducer.UIState.EmptyState?) -> some View {
        Group {
            if let emptyState {
                switch emptyState {
                case .allTasksComplete:
                    Text("All Tasks Complete")
                        .font(.title3)
                        .foregroundColor(UIColor.label.asColor)
                case .noTasks:
                    Text("No tasks")
                        .font(.title3)
                        .foregroundColor(UIColor.label.asColor)
                }
            }
        }
    }
}

struct PlannerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerHomeView(
            store: Store(
                initialState: PlannerHomeReducer.State(
                    project: TodoListProject(),
                    allProjects: []
                ),
                reducer: PlannerHomeReducer()
            )
        )
    }
}
