import XCTest
import ComposableArchitecture

@testable import TomatoTimer

@MainActor
final class CreateFocusProjectReducerTests: XCTestCase {

    func createTestStore(
        initialState: CreateFocusProjectReducer.State = .init()
    ) -> TestStoreOf<CreateFocusProjectReducer> {
        return TestStoreOf<CreateFocusProjectReducer>(
            initialState: initialState,
            reducer: CreateFocusProjectReducer()
        )
    }

    func test_viewDidAppear_should_monitor() async {

    }

//    func test_setUserAccessLevel_should_set() async {
//        let sut = createTestStore()
//
//        await sut.send(.setUserAccessLevel(.lifetime)) {
//            $0.userAccessLevel = .lifetime
//        }
//    }

    func test_dismissButtonPressed() async {
        let sut = createTestStore()

        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({ isDismissInvoked.setValue(true) })
        await sut.send(.dismissButtonPressed)
        XCTAssertTrue(isDismissInvoked.value)
    }

    func test_done_button_pressed_should_save_project() async {
    }

    func test_timer_type_row_pressed_should_present_select_timer_type() async {
        let sut = createTestStore()

        await sut.send(.timerTypeRowPressed) {
            $0.path.append(
                .selectTimerType(
                    SelectTimerTypeReducer.State(
                        selectedType: sut.state.timerType)
                )
            )
        }
    }

    func test_list_type_row_pressed_should_present_select_list_type() async {
        let sut = createTestStore()

        await sut.send(.listTypeRowPressed) {
            $0.path.append(.selectListType(
                SelectListTypeReducer.State(
                    selectedTimerType: sut.state.timerType,
                    selectedListType: sut.state.project.list
                )
            ))
        }
    }

    func test_work_sound_row_pressed_should_present_select_work_sound() async {
        let sut = createTestStore()

        await sut.send(.workSoundRowPressed) {
            $0.path.append(
                .selectWorkSound(
                    SelectNotificationSoundReducer.State(sound: sut.state.workSound)
                )
            )
        }
    }

    func test_setting_work_sound_should_set_break_sound_if_not_subscribed() async {
        let sut = createTestStore()

        sut.dependencies.services = MockServices()
        await sut.send(.workSoundRowPressed) {
            $0.path.append(
                .selectWorkSound(
                    SelectNotificationSoundReducer.State(sound: sut.state.workSound)
                )
            )
        }

        await sut.send(.path(.element(id: 0, action: .selectWorkSound(.selectedSound(.coins))))) {
            $0.workSound = .coins
            $0.breakSound = .coins
            $0.path.pop(from: 0)
        }
    }

    func test_setting_work_sound_should_set_work_sound_if_subscribed() async {
        let sut = createTestStore()

        sut.dependencies.services = MockServices()
        await sut.send(.setDidPurchasePlus(true)) {
            $0.didPurchasePlus = true
        }

        await sut.send(.workSoundRowPressed) {
            $0.path.append(
                .selectWorkSound(
                    SelectNotificationSoundReducer.State(sound: sut.state.workSound)
                )
            )
        }

        await sut.send(.path(.element(id: 0, action: .selectWorkSound(.selectedSound(.coins))))) {
            $0.workSound = .coins
            $0.path.pop(from: 0)
        }
    }

    func test_setting_work_sound_should_do_nothing_if_pro_sound_and_not_subscribed() async {

    }

    func test_break_sound_row_pressed_should_present_paywall() async {
        let sut = createTestStore()

        await sut.send(.breakSoundRowPressed) {
            $0.paywall = .init()
        }
    }

    func test_break_sound_row_pressed_should_present_select_break_sound() async {
        let sut = createTestStore()

        await sut.send(.setDidPurchasePlus(true)) {
            $0.didPurchasePlus = true
        }
        await sut.send(.breakSoundRowPressed) {
            $0.path.append(
                .selectBreakSound(
                    SelectNotificationSoundReducer.State(sound: sut.state.breakSound)
                )
            )
        }
    }

    func test_set_timer_title_should_set_title() async {
        let sut = createTestStore()

        await sut.send(.setTitle("title")) {
            $0.project.title = "title"
        }
    }

    func test_set_emoji_should_set_emoji() async {
        let sut = createTestStore()

        await sut.send(.setEmoji("🍅")) {
            $0.project.emoji = "🍅"
        }
    }

    func test_set_theme_color_should_set_theme_color() async {
        let sut = createTestStore()

        await sut.send(.selectedThemeColor(.appBlue)) {
            $0.project.themeColor = .appBlue
        }
    }

    func set_work_length_should_set_work_length() async {
        let sut = createTestStore()

        await sut.send(.setWorkLength(1)) {
            $0.workSessionLength = 1 * 60
        }
    }

    func set_short_break_length_should_set_short_break_length() async {
        let sut = createTestStore()

        await sut.send(.setShortBreakLength(1)) {
            $0.shortBreakLength = 1 * 60
        }
    }

    func test_set_long_break_long_should_set_long_break_length() async {
        let sut = createTestStore()

        await sut.send(.setLongBreakLength(43)) {
            $0.longBreakLength = 43 * 60
        }
    }

    func test_set_number_of_sessions_sets_number_of_sessions() async {
        let sut = createTestStore()

        await sut.send(.setNumberOfSessions(8)) {
            $0.sessionCount = 8
        }
    }

    func test_changing_number_of_sessions_for_session_list_and_standard_timer_adds_tasks() async {
        let uuid = UUID()
        let sut = TestStoreOf<CreateFocusProjectReducer>(
            initialState: CreateFocusProjectReducer.State(
                project: .init(list: .session(.init(id: uuid, tasks: [])))
            ),
            reducer: CreateFocusProjectReducer()
        )

        sut.dependencies.uuid = .constant(uuid)
        await sut.send(.setNumberOfSessions(8)) {
            $0.sessionCount = 8
            $0.project.list = .session(.init(id: uuid, tasks: (0..<8).map { num in
                FocusListTask(id: uuid, title: "Untitled Task \(num + 1)", completed: false, inProgress: num == 0, order: num)
            }))
        }
    }

    func test_selecting_timer_type_sets_timer_type() async {
    }

    func test_selecting_list_type_sets_list_type() async {

    }

}
