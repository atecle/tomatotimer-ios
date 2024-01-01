import SwiftUI
import ComposableArchitecture

struct ProjectsView: View {

    // MARK: - Properties

    @SwiftUI.Environment(\.dismiss) var dismiss
    @State var addProjectTitle = ""
    @State var presentAddProject = false
    let store: StoreOf<ProjectsReducer>

    init(store: StoreOf<ProjectsReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {

                // MARK: - List

                List {
                    ForEach(viewStore.projects) { project in
                        HStack {
                            Text("\(project.title)")
                            Spacer()
                            Image(systemName: "checkmark")
                                .isHidden(!project.isActive)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.setActive(project))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if viewStore.projects.count > 1 && !project.isActive {
                                Button("Delete") {
                                    viewStore.send(.deleteButtonPressed(project))
                                }
                            }
                        }
                        .confirmationDialog(
                            "Are you sure you want to delete this project?",
                            isPresented: viewStore.binding(
                                get: \.isConfirmDeletionAlertPresented,
                                send: { .setConfirmDeletionAlertPresented($0) }
                            ),
                            titleVisibility: .visible,
                            actions: {
                                Button(role: .destructive) {
                                    viewStore.send(.deleteProject)
                                } label: {
                                    Text("Delete")
                                }
                        })
                    }
                    .deleteDisabled(viewStore.state.projects.count == 1)
                }
                .navigationTitle("Projects")

                // MARK: - Transitions

                .alert(
                    "Create a project",
                    isPresented: $presentAddProject
                ) {
                    TextField("Project title", text: $addProjectTitle)
                    Button("Add") {
                        viewStore.send(.addProject(addProjectTitle))
                        presentAddProject = false
                        addProjectTitle = ""
                    }
                }

                // MARK: - Navigation Bar Items

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: dismiss.callAsFunction) {
                            Image(systemName: "xmark")
                                .foregroundColor(UIColor.label.asColor)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentAddProject = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(UIColor.label.asColor.opacity(viewStore.canAddMoreProjects ? 1 : 0.2))
                        }
                        .disabled(!viewStore.canAddMoreProjects)
                    }
                }
            }
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var currentProject = TodoListProject()
    static var previews: some View {
        ProjectsView(
            store: Store(
                initialState: ProjectsReducer.State(
                    currentProject: currentProject, projects: [currentProject]
                ),
                reducer: ProjectsReducer()
            )
        )
    }
}
