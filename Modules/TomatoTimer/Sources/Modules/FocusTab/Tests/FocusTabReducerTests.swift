import XCTest
import ComposableArchitecture

@testable import TomatoTimer

@MainActor
final class FocusTabReducerTests: XCTestCase {

    func test_plus_button_pressed_should_show_create_timer() async {
        let sut = TestStoreOf<FocusTabReducer>(
            initialState: FocusTabReducer.State(),
            reducer: FocusTabReducer()
        )

        let date = Date()
        let uuid = UUID()
        let emoji = "🍅"
        sut.dependencies.emoji = .constant(emoji)
        sut.dependencies.date = .constant(date)
        sut.dependencies.uuid = .constant(uuid)
        await sut.send(.plusButtonPressed) {
            $0.createTimer = CreateFocusProjectReducer.State(
                project: .init(
                    id: uuid, creationDate: date,
                    scheduledDate: date,
                    emoji: emoji,
                    list: .singleTask(.init(id: uuid)),
                    timer: .standard(.init(id: uuid))
                ),
                isEditing: false
            )
        }
    }

    func test_plus_button_pressed_should_show_paywall_if_timer_already_created_for_today() async {
        let date = Calendar.current.startOfDay(for: Date())
        let sut = TestStoreOf<FocusTabReducer>(
            initialState: FocusTabReducer.State(
                loadedProjects: [date: [.init()]]
            ),
            reducer: FocusTabReducer()
        )

        let uuid = UUID()
        sut.dependencies.date = .constant(date)
        sut.dependencies.uuid = .constant(uuid)
        await sut.send(.plusButtonPressed) {
            $0.paywall = .init()
        }
    }

    func test_selected_project_recurrence_template_should_create_project() async throws {
        let sut = TestStoreOf<FocusTabReducer>(
            initialState: FocusTabReducer.State(
            ),
            reducer: FocusTabReducer()
        )

        let uuid = UUID()
        let date = Calendar.current.startOfDay(for: Date())
        sut.dependencies.date = .constant(date)
        sut.dependencies.uuid = .constant(uuid)
        var project = FocusProject()
        project.recurrenceTemplate = .init()
        await sut.send(.selectedProject(project)) {
            $0.selectedFocusProject = FocusProject(
                id: uuid,
                title: project.title,
                creationDate: date,
                scheduledDate: date,
                emoji: project.emoji,
                themeColor: project.themeColor,
                list: project.list.newInstance(uuid: { return uuid }),
                timer: project.timer.newInstance(uuid: { return uuid }),
                isActive: true,
                recurrence: project.recurrenceTemplate,
                recurrenceTemplate: nil
            )

            $0.path.append(
                .timerHome(
                    FocusProjectReducer.State(
                        project: $0.selectedFocusProject!,
                        timer: TimerReducer.State(
                            project: $0.selectedFocusProject!
                        ),
                        list: FocusListReducer.State(
                            project: $0.selectedFocusProject!
                        )
                    )
                )
            )
        }
    }

    func test_selected_project() async throws {
        let sut = TestStoreOf<FocusTabReducer>(
            initialState: FocusTabReducer.State(
            ),
            reducer: FocusTabReducer()
        )

        let uuid = UUID()
        let date = Calendar.current.startOfDay(for: Date())
        sut.dependencies.date = .constant(date)
        sut.dependencies.uuid = .constant(uuid)
        var project = FocusProject()
        await sut.send(.selectedProject(project)) {
            project.isActive = true
            $0.selectedFocusProject = project

            $0.path.append(
                .timerHome(
                    FocusProjectReducer.State(
                        project: $0.selectedFocusProject!,
                        timer: TimerReducer.State(
                            project: $0.selectedFocusProject!
                        ),
                        list: FocusListReducer.State(
                            project: $0.selectedFocusProject!
                        )
                    )
                )
            )
        }
    }

}
