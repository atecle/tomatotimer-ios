//
//  TimerReducerTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/23/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import ComposableArchitecture
import ComposableUserNotifications

@testable import TomatoTimer

@MainActor
final class TomatoTimerReducerTests: XCTestCase {

    func test_toggleIsRunning() async {
        let testClock = TestClock()

        let (sut) = createTestDeps()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.toggleIsRunning) {
            $0.tomatoTimer.isRunning.toggle()
        }
        await sut.receive(.setAnimation(.pristineToStarted)) {
            $0.animation = .pristineToStarted
        }
        await sut.receive(.requestAuthorizationResponse(.success(true))) {
            $0.notificationAuthorizationStatus = .authorized
        }
        await sut.send(.setAnimation(nil)) {
            $0.animation = nil
        }
        await testClock.advance(by: .seconds(1))
        await sut.receive(.decrementTime) {
            $0.tomatoTimer.decrementTime()
        }
        await sut.send(.toggleIsRunning) {
            $0.tomatoTimer.isRunning.toggle()
        }
    }

    func test_toggleIsRunning_does_nothing_if_animation_in_progress() async {
        let testClock = TestClock()

        let (sut) = createTestDeps(animation: .pristineToStarted)
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.toggleIsRunning)
    }

    func test_restartTimer_does_nothing_if_not_begun() async {
        let testClock = TestClock()

        let (sut) = createTestDeps()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.restartTimer)
    }

    func test_restartTimer() async {
        let testClock = TestClock()

        var timer = TomatoTimer()
        timer.isRunning = true
        timer.decrementTime()
        let (sut) = createTestDeps(timer: timer)
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.restartTimer) {
            $0.tomatoTimer.restartTimer()
        }
        await sut.receive(.setAnimation(.startedToPristine(secondsLeft: 1499, totalSeconds: 1500))) {
            $0.animation = .startedToPristine(secondsLeft: 1499, totalSeconds: 1500)
        }
    }

    func test_restartSession_does_nothing_if_not_begun() async {
        let testClock = TestClock()

        let (sut) = createTestDeps()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.restartSession)
    }

    func test_restartSession_begun_and_running() async {
        let testClock = TestClock()

        var timer = TomatoTimer()
        timer.isRunning = true
        timer.decrementTime()
        let (sut) = createTestDeps(timer: timer)
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.restartSession) {
            $0.tomatoTimer.restartSession()
        }
        await sut.receive(.setAnimation(.refill(secondsLeft: 1499, totalSeconds: 1500))) {
            $0.animation = .refill(secondsLeft: 1499, totalSeconds: 1500)
        }
    }

    func test_restartSession_begun_and_not_running() async {
        let testClock = TestClock()

        var timer = TomatoTimer()
        timer.decrementTime()
        let (sut) = createTestDeps(timer: timer)
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.restartSession) {
            $0.tomatoTimer.restartSession()
        }
        await sut.receive(.setAnimation(.startedToPristine(secondsLeft: 1499, totalSeconds: 1500))) {
            $0.animation = .startedToPristine(secondsLeft: 1499, totalSeconds: 1500)
        }
    }

    func test_complete_just_completes_if_not_begun() async {
        let testClock = TestClock()

        let (sut) = createTestDeps()
        sut.dependencies.continuousClock = testClock
        sut.dependencies.userNotifications = .testValue
        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
        sut.dependencies.userNotifications.delegate = { delegate.stream }

        await sut.send(.complete) {
            $0.tomatoTimer.complete()
        }
    }

//    func test_complete_if_begun_running_and_last_session() async {
//        let testClock = TestClock()
//
//        var timer = TomatoTimer()
//        timer.isRunning = true
//        timer.decrementTime()
//        let (sut) = createTestDeps(timer: timer)
//        sut.dependencies.continuousClock = testClock
//        sut.dependencies.userNotifications = .testValue
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//
//        await sut.send(.restartSession) {
//            $0.tomatoTimer.restartSession()
//        }
//        await sut.receive(.setAnimation(.refill(secondsLeft: 1499, totalSeconds: 1500))) {
//            $0.animation = .refill(secondsLeft: 1499, totalSeconds: 1500)
//        }
//    }
//
//    func test_complete_begun_and_not_running() async {
//        let testClock = TestClock()
//
//        var timer = TomatoTimer()
//        timer.decrementTime()
//        let (sut) = createTestDeps(timer: timer)
//        sut.dependencies.continuousClock = testClock
//        sut.dependencies.userNotifications = .testValue
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//
//        await sut.send(.restartSession) {
//            $0.tomatoTimer.restartSession()
//        }
//        await sut.receive(.setAnimation(.startedToPristine(secondsLeft: 1499, totalSeconds: 1500))) {
//            $0.animation = .startedToPristine(secondsLeft: 1499, totalSeconds: 1500)
//        }
//    }

//    func test_when_navigating_away_from_the_app_for_a_minute_and_return_elapsed_time_is_set_correctly() async {
//        let project = TodoListProject() // needed for fetch logic
//        var timer = TomatoTimer()
//        let settings = Settings()
//        timer.isRunning = true
//        let mockServices = MockServices()
//        let testClock = TestClock()
//        let now = Date(timeIntervalSince1970: 748656000) // 09/22/1993 12:00:00am
//        let appTerminatedDate = now.addingTimeInterval(-60) // 09/21/1993 11:59:00am
//        mockServices.mockUserDefaultsService.getValueResponse = appTerminatedDate
//        mockServices.mockTimerService.tomatoTimer = timer
//        mockServices.mockProjectService.project = project
//        mockServices.mockSettingsService.storedSettings = settings
//
//        let (store) = createTestDeps(timer: timer, settings: settings, mockServices: mockServices)
//        store.dependencies.date = DateGenerator({ return now })
//        store.dependencies.continuousClock = testClock
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        store.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        store.dependencies.userNotifications.notificationSettings = {
//            let notifSettings = await UNUserNotificationCenter.current().notificationSettings()
//            var settings = Notification.Settings(rawValue: notifSettings)
//            settings.authorizationStatus = { .authorized }
//            return settings
//        }
//        store.dependencies.userNotifications.requestAuthorization = { _ in return true }
//        store.dependencies.userNotifications.delegate = { delegate.stream }
//
//        await store.send(.viewDidAppear)
//        await store.receive(.loadTimer(timer)) { state in
//            state.tomatoTimer.isRunning = true
//            state.tomatoTimer.setTimeElapsed(60)
//        }
//        await store.receive(.loadSettings(settings))
//        await store.receive(.setNotificationAuthorizationStatus(.authorized)) {
//            $0.notificationAuthorizationStatus = .authorized
//        }
//
//        await testClock.advance(by: .seconds(1))
//        await store.receive(.decrementTime) {
//            $0.tomatoTimer.decrementTime()
//        }
//        await store.send(.toggleIsRunning) {
//            $0.tomatoTimer.isRunning.toggle()
//        }
//        await store.skipInFlightEffects()
//    }

    func createTestDeps(
        timer: TomatoTimer = .init(),
        settings: Settings = .init(),
        mockServices: MockServices = .init(),
        animation: TomatoTimerReducer.Animation? = nil
    ) -> (
        TestStore<TomatoTimerReducer.State, TomatoTimerReducer.Action, TomatoTimerReducer.State, TomatoTimerReducer.Action, ()>
    ) {
        let store = TestStore(
            initialState: TomatoTimerReducer.State(
                animation: animation,
                tomatoTimer: timer,
                settings: settings
            ),
            reducer: TomatoTimerReducer()
        )

        store.dependencies.services = mockServices

        return (store)
    }

}
