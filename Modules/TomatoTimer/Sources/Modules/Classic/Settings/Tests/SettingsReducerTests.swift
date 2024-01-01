import XCTest
import ComposableArchitecture
import UIColorHexSwift
@testable import TomatoTimer

@MainActor
final class SettingsReducerTests: XCTestCase {

    func test_changing_work_session_length_updates_settings_and_timer_correctly() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }

        let length = 15
        await store.send(.setWorkLength(length)) { state in
            state.settings.timerConfig.totalSecondsInWorkSession = length * 60
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_short_break_session_length_updates_settings_and_timer_correctly() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let length = 15
        await store.send(.setShortBreakLength(length)) { state in
            state.settings.timerConfig.totalSecondsInShortBreakSession = length * 60
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_long_break_session_length_updates_settings_and_timer_correctly() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let length = 99
        await store.send(.setLongBreakLength(length)) { state in
            state.settings.timerConfig.totalSecondsInLongBreakSession = length * 60
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_number_of_sessions_updates_settings_and_timer_correctly() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let number = 2
        await store.send(.setNumberOfSessions(number)) { state in
            state.settings.timerConfig.numberOfTimerSessions = number
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_notification_sound_updates_work_and_break_sound() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        XCTAssertEqual(
            store.state.settings.notificationSettings,
            NotificationSettings(workSound: .default, breakSound: .default, purchasedPro: false)
        )
        for sound in NotificationSound.allCases.filter({ $0 != .default }) {
            await store.send(.setNotificationSound(sound)) { state in
                state.settings.workSound = sound
                state.settings.breakSound = sound
            }
            await store.receive(.playNotificationSound(sound))
        }
    }

    func test_changing_keep_device_awake_sets_state_correctly() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        let awake = false
        await store.send(.setKeepDeviceAwake(awake)) { state in
            state.settings.keepDeviceAwake = awake
        }
    }

    func test_changing_autostart_next_session_updates_for_work_and_break_session() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let autostart = false
        await store.send(.setAutostartNextSession(autostart)) { state in
            state.settings.timerConfig.shouldAutostartNextWorkSession = autostart
            state.settings.timerConfig.shouldAutostartNextBreakSession = autostart
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_autostart_next_work_session_just_changes_work_session() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let autostart = false
        await store.send(.setAutostartNextWorkSession(autostart)) { state in
            state.settings.timerConfig.shouldAutostartNextWorkSession = autostart
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_autostart_next_short_break_session_just_changes_break_session() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        store.dependencies.userNotifications = .testValue
        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        store.dependencies.userNotifications.add = { _ in }
        let autostart = false
        await store.send(.setAutostartNextBreakSession(autostart)) { state in
            state.settings.timerConfig.shouldAutostartNextBreakSession = autostart
            state.timer.update(with: state.settings.timerConfig)
        }
    }

    func test_changing_theme_color_updates_theme_color() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer())
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        for color in UIColor.themeColors.filter({ $0.hexString() != UIColor.defaultThemeColor.hexString() }) {
            await store.send(.setThemeColor(color)) { state in
                state.settings.themeColor = color
                state.settings.usingCustomColor = false
            }
        }
    }

    func test_changing_custom_theme_color_updates_theme_color_and_marks_custom_theme_color_in_use() async {
        let store = TestStore(
            initialState: ClassicSettingsReducer.State(
                timer: .init(),
                settings: .init()
            ),
            reducer: ClassicSettingsReducer()
        )
        let mockServices = MockServices()
        store.dependencies.services = mockServices
        await store.send(.setCustomThemeColor(.blue)) { state in
            state.settings.themeColor = .blue
            state.settings.usingCustomColor = true
        }
    }
}
