//
//  MockServices.swift
//  TomatoTimerTests
//
//  Created by adam on 7/4/20.
//  Copyright © 2020 Adam Tecle. All rights reserved.
//

import Foundation
import StoreKit
import Combine
import ComposableArchitecture

class MockTimerService: TimerServiceType {

    var standardTimer = StandardTimer()
    func monitor(_ timer: StandardTimer) -> AnyPublisher<StandardTimer, Error> {
        Just(standardTimer).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func monitor(for date: Date) -> AnyPublisher<[FocusProject], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func save(project: FocusProject) async throws {
    }

    var tomatoTimer = TomatoTimer()

    func timer() -> AnyPublisher<TomatoTimer, Swift.Error> {
        Just(tomatoTimer).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func fetch(for date: Date) async throws -> [FocusProject] {
        return []
    }

    func fetchAll() async throws -> [TomatoTimer] {
        return []
    }

    func monitor() -> AnyPublisher<[TomatoTimer], Error> {
        Just([tomatoTimer]).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func add(_ timer: TomatoTimer) async throws {
    }

    func update(_ timer: TomatoTimer) async throws {
    }

    func monitor(_ timer: FocusTimer) -> AnyPublisher<FocusTimer, Error> {
        fatalError()
    }

    func update(_ timer: FocusTimer) async throws {
    }

    func update(_ timer: StandardTimer) async throws {
    }

}

class MockTimerNotificationService: TimerNotificationServiceType {
    func localNotifications(for timer: StandardTimer, config: LocalNotificationConfig) -> [LocalNotification] {
        return []
    }

    var notificationsOnceValue: [LocalNotification] = []
    func notificationsOnce(for timerState: TomatoTimer, notificationSettings: NotificationSettings) -> [LocalNotification] {
        return notificationsOnceValue
    }

}

class MockSettingsService: SettingsServiceType {

    var storedSettings = Settings()

    var useStoredSettings = true

    func fetchAll() async throws -> [Settings] {
        return []
    }

    func settings() -> AnyPublisher<Settings, Error> {
        Just(storedSettings).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func monitor() -> AnyPublisher<[Settings], Error> {
        Just([storedSettings]).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func add(_ settings: Settings) async throws {
    }

    func update(_ settings: Settings) async throws {
    }

}

class MockProjectService: ProjectServiceType {

    var project: TodoListProject = TodoListProject.default
    var projects: [TodoListProject] = [TodoListProject.default]

    func currentProject() -> AnyPublisher<TodoListProject, Error> {
        Just(project).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func monitor() -> AnyPublisher<[TodoListProject], Error> {
        Just([project]).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
    }

    func fetchAll() async throws -> [TodoListProject] {
        return []
    }

    func add(_ project: TodoListProject) async throws {
    }

    func update(_ project: TodoListProject) async throws {
    }

    func delete(_ project: TodoListProject) async throws {
    }

}
