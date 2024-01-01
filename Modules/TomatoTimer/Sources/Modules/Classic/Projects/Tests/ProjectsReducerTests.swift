import XCTest
import ComposableArchitecture
@testable import TomatoTimer

@MainActor
final class ProjectsReducerTests: XCTestCase {

    func test_setActive_sets_current_project_and_marks_other_projects_inactive() async throws {
        var currentProject = TodoListProject()
        let otherProject = TodoListProject()
        let projects = [currentProject, otherProject]
        let sut = TestStoreOf<ProjectsReducer>(
            initialState: ProjectsReducer.State(
                currentProject: otherProject,
                projects: projects
            ),
            reducer: ProjectsReducer()
        )
        let mockServices = MockServices()
        let now = Date()

        sut.dependencies.date = .constant(now)
        sut.dependencies.services = mockServices

        currentProject.isActive = true
        await sut.send(.setActive(currentProject)) {
            $0.currentProject = currentProject
            $0.currentProject.isActive = true
            $0.projects = [currentProject, otherProject]
        }
    }

    func test_delete_removes_project() async throws {
        let currentProject = TodoListProject()
        let otherProject = TodoListProject()
        let projects = [currentProject, otherProject]
        let sut = TestStoreOf<ProjectsReducer>(
            initialState: ProjectsReducer.State(
                currentProject: otherProject,
                projects: projects,
                projectForDeletion: currentProject
            ),
            reducer: ProjectsReducer()
        )
        let mockServices = MockServices()
        let now = Date()

        sut.dependencies.date = .constant(now)
        sut.dependencies.services = mockServices

        await sut.send(.deleteProject) {
            $0.currentProject = otherProject
            $0.projects = [otherProject]
        }
    }

    func test_add_project() async throws {
        let currentProject = TodoListProject()
        let projects = [currentProject]
        let sut = TestStoreOf<ProjectsReducer>(
            initialState: ProjectsReducer.State(
                currentProject: currentProject,
                projects: projects
            ),
            reducer: ProjectsReducer()
        )
        let mockServices = MockServices()
        let now = Date()
        let uuid = UUID()
        let addedProject = TodoListProject(id: uuid, title: "Added", lastOpenedDate: now)

        sut.dependencies.date = .constant(now)
        sut.dependencies.services = mockServices
        sut.dependencies.uuid = .constant(uuid)

        await sut.send(.addProject("Added")) {
            $0.currentProject = currentProject
            $0.projects = [currentProject, addedProject]
        }
    }
}
