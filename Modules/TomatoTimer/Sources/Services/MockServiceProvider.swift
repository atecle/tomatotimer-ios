import Foundation
import UserNotifications
import StoreKit
import Combine

struct MockServices: ServiceProvider {

    var mockTimerNotificationService = MockTimerNotificationService()
    var timerNotificationService: TimerNotificationServiceType { mockTimerNotificationService }

    var mockTimerService = MockTimerService()
    var timerService: TimerServiceType { mockTimerService }

    var mockSettingsService = MockSettingsService()
    var settingsService: SettingsServiceType { mockSettingsService }

    var mockProjectService = MockProjectService()
    var projectService: ProjectServiceType { mockProjectService }

    var mockFocusListService = MockFocusListService()
    var focusListService: FocusListServiceType { mockFocusListService }
    var mockFocusProjectService = MockFocusProjectService()
    var focusProjectService: FocusProjectServiceType { mockFocusProjectService }

    var mockUserDefaultsService = MockUserDefaultsService()
    var userDefaultsService: UserDefaultsServiceType { mockUserDefaultsService }

    var mockAudioPlayer = MockAudioPlayerService()
    var audioPlayer: AudioPlayerServiceType { mockAudioPlayer }

}

class MockUserDefaultsService: UserDefaultsServiceType {

    var getValueResponse: Any?
    func getValue<T>(key: UserDefaults.Key) -> T? {
        return getValueResponse as? T
    }

    var setValue: Any?
    func setValue<T>(key: UserDefaults.Key, value: T) {
        setValue = value
    }
}

struct MockAudioPlayerService: AudioPlayerServiceType {
    func playNotificationSound(_ sound: NotificationSound) {

    }
}

struct MockFocusListService: FocusListServiceType {
    func update(_ list: FocusList) async throws {
    }

    var list = StandardList()
    func monitor(_ list: StandardList) -> AnyPublisher<StandardList, Error> {
        Just(list).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func monitor(_ list: FocusList) -> AnyPublisher<FocusList, Error> {
        Just(.none).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func save(_ list: FocusList) async throws {

    }
}

struct MockFocusProjectService: FocusProjectServiceType {
    func delete(_ project: FocusProject) async throws {
    }

    let project = FocusProject()
    func monitor(_ focusProject: FocusProject) -> AnyPublisher<FocusProject, Error> {
        Just(project).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func monitor(for date: Date) -> AnyPublisher<[FocusProject], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func create(_ project: FocusProject) async throws {
    }
    func update(_ project: FocusProject) async throws {

    }
}
