//import XCTest
//import ComposableArchitecture
//import ComposableUserNotifications
//
// swiftlint:disable all
//
//@testable import TomatoTimer
//
//@MainActor
//final class StandardTimerReducerTests: XCTestCase {
//
//    func test_on_appear_should_receive_user_notification_delegate_actions() async {
//        let timer = StandardTimer()
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer),
//            reducer: StandardTimerReducer()
//        )
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let services = MockServices()
//        services.mockTimerService.standardTimer = timer
//        sut.dependencies.services = services
//        
//        await sut.send(.onAppear)
//        await sut.receive(.setTimer(timer))
//        await sut.send(.cancelEffect(.notifications))
//    }
//
//    func test_toggle_is_running_returns_early_if_animation_in_progress() async {
//        let timer = StandardTimer()
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer, animation: .finishedToPristine),
//            reducer: StandardTimerReducer()
//        )
//
//        await sut.send(.toggleIsRunning)
//    }
//
//    func test_toggle_is_running_first_time() async {
//        let timer = StandardTimer()
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer),
//            reducer: StandardTimerReducer()
//        )
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let clock = TestClock()
//        let mockServices = MockServices()
//        sut.dependencies.continuousClock = clock
//        sut.dependencies.services = mockServices
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.add = { _ in }
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        await sut.receive(.setAnimation(.pristineToStarted)) {
//            $0.animation = .pristineToStarted
//        }
//        await sut.receive(.requestAuthorizationResponse(.success(true)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//    }
//
//    func test_restart_timer() async {
//        let id = UUID()
//        let timer = StandardTimer(id: id)
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer, incompleteTaskCount: 1),
//            reducer: StandardTimerReducer()
//        )
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let clock = TestClock()
//        let mockServices = MockServices()
//        sut.dependencies.continuousClock = clock
//        sut.dependencies.services = mockServices
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.add = { _ in }
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        await sut.receive(.setAnimation(.pristineToStarted)) {
//            $0.animation = .pristineToStarted
//        }
//        await sut.receive(.requestAuthorizationResponse(.success(true)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.restartTimer) {
//            $0.timer.restartTimer()
//        }
//
//        await sut.receive(.setAnimation(.startedToPristine(secondsLeft: 59, totalSeconds: 60))) {
//            $0.animation = .startedToPristine(secondsLeft: 59, totalSeconds: 60)
//        }
//
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//    }
//
//    func test_restart_session() async {
//        let config = StandardTimerConfiguration(
//            workSessionLength: 60,
//            shortBreakLength: 60,
//            longBreakLength: 60,
//            sessionCount: 4,
//            autostartWorkSession: true,
//            autostartBreakSession: true
//        )
//
//        let timer = StandardTimer(config: config)
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer, incompleteTaskCount: 1),
//            reducer: StandardTimerReducer()
//        )
//
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let clock = TestClock()
//        let mockServices = MockServices()
//        sut.dependencies.continuousClock = clock
//        sut.dependencies.services = mockServices
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.add = { _ in }
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        await sut.receive(.setAnimation(.pristineToStarted)) {
//            $0.animation = .pristineToStarted
//        }
//        await sut.receive(.requestAuthorizationResponse(.success(true)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        // Work Session 1 / 4
//        for _ in 0..<60 {
//            await clock.advance(by: .seconds(1))
//            await sut.receive(.timerTick) {
//                $0.timer.decrementTime()
//            }
//            //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        }
//
//        // Animation
//        XCTAssertEqual(sut.state.timer.currentSession, .work)
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
//        XCTAssertEqual(sut.state.timer.completedSessionCount, 0)
//        await sut.receive(.setAnimation(.startNextSession)) {
//            $0.animation = .startNextSession
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.restartSession) {
//            $0.timer.restartSession()
//        }
//
//        await sut.receive(.setAnimation(.refill(secondsLeft: 59, totalSeconds: 60))) {
//            $0.animation = .refill(secondsLeft: 59, totalSeconds: 60)
//        }
//
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.cancelEffect(.timer))
//    }
//
//    func test_complete_session() async {
//        let config = StandardTimerConfiguration(
//            workSessionLength: 60,
//            shortBreakLength: 60,
//            longBreakLength: 60,
//            sessionCount: 4,
//            autostartWorkSession: true,
//            autostartBreakSession: true
//        )
//
//        let timer = StandardTimer(config: config)
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer, incompleteTaskCount: 1),
//            reducer: StandardTimerReducer()
//        )
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let clock = TestClock()
//        let mockServices = MockServices()
//        sut.dependencies.continuousClock = clock
//        sut.dependencies.services = mockServices
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.add = { _ in }
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        await sut.receive(.setAnimation(.pristineToStarted)) {
//            $0.animation = .pristineToStarted
//        }
//        await sut.receive(.requestAuthorizationResponse(.success(true)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        // Work Session 1 / 4
//        for _ in 0..<60 {
//            await clock.advance(by: .seconds(1))
//            await sut.receive(.timerTick) {
//                $0.timer.decrementTime()
//            }
//            //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        }
//
//        // Animation
//        XCTAssertEqual(sut.state.timer.currentSession, .work)
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
//        XCTAssertEqual(sut.state.timer.completedSessionCount, 0)
//        await sut.receive(.setAnimation(.startNextSession)) {
//            $0.animation = .startNextSession
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.complete(toNextWorkSession: false)) {
//            $0.timer.complete()
//        }
//
//        await sut.receive(.setAnimation(.completeAndContinue(secondsLeft: 59, totalSeconds: 60))) {
//            $0.animation = .completeAndContinue(secondsLeft: 59, totalSeconds: 60)
//        }
//
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//
//        await sut.send(.cancelEffect(.timer))
//    }
////
////    func test_cannot_restart_or_complete_if_task_count_is_zero() async {
////        let config = StandardTimerConfiguration(
////            workSessionLength: 60,
////            shortBreakLength: 60,
////            longBreakLength: 60,
////            sessionCount: 4,
////            autostartWorkSession: true,
////            autostartBreakSession: true
////        )
////
////        let timer = StandardTimer(config: config)
////        let sut = TestStoreOf<StandardTimerReducer>(
////            initialState: StandardTimerReducer.State(timer: timer, list: .standard(.init(tasks: [.init()]))),
////            reducer: StandardTimerReducer()
////        )
////
////
////        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
////        sut.dependencies.userNotifications.delegate = { delegate.stream }
////        let clock = TestClock()
////        let mockServices = MockServices()
////        sut.dependencies.continuousClock = clock
////        sut.dependencies.services = mockServices
////        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
////        sut.dependencies.userNotifications.add = { _ in }
////        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
////
////        await sut.send(.toggleIsRunning) {
////            $0.timer.isRunning.toggle()
////        }
////        await sut.receive(.setAnimation(.pristineToStarted)) {
////            $0.animation = .pristineToStarted
////        }
////        await sut.receive(.requestAuthorizationResponse(.success(true)))
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
////
////        await sut.send(.pause) {
////            $0.timer.isRunning = false
////        }
////        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
////        await sut.send(.restartTimer)
////        await sut.send(.restartTimer)
////        await sut.send(.restartSession)
////
////        await sut.send(.cancelEffect(.timer))
////    }
//
//    func test_timer_works_when_set_to_minimum_session_length_and_4_sessions() async {
//        let config = StandardTimerConfiguration(
//            workSessionLength: 60,
//            shortBreakLength: 60,
//            longBreakLength: 60,
//            sessionCount: 4,
//            autostartWorkSession: true,
//            autostartBreakSession: true
//        )
//
//        let timer = StandardTimer(config: config)
//        let sut = TestStoreOf<StandardTimerReducer>(
//            initialState: StandardTimerReducer.State(timer: timer),
//            reducer: StandardTimerReducer()
//        )
//
//        let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.makeStream()
//        sut.dependencies.userNotifications.delegate = { delegate.stream }
//        let clock = TestClock()
//        let mockServices = MockServices()
//        sut.dependencies.continuousClock = clock
//        sut.dependencies.services = mockServices
//        sut.dependencies.userNotifications.removeAllPendingNotificationRequests = {}
//        sut.dependencies.userNotifications.add = { _ in }
//        sut.dependencies.userNotifications.requestAuthorization = { _ in return true }
//
//        await sut.send(.toggleIsRunning) {
//            $0.timer.isRunning.toggle()
//        }
//        await sut.receive(.setAnimation(.pristineToStarted)) {
//            $0.animation = .pristineToStarted
//        }
//        await sut.receive(.requestAuthorizationResponse(.success(true)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
//        // Work Session 1 / 4
//        for _ in 0..<60 {
//            await clock.advance(by: .seconds(1))
//            await sut.receive(.timerTick) {
//                $0.timer.decrementTime()
//            }
//            //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        }
//
//        // Animation
//        XCTAssertEqual(sut.state.timer.currentSession, .work)
//        await clock.advance(by: .seconds(1))
//        await sut.receive(.timerTick) {
//            $0.timer.decrementTime()
//        }
//        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
//        XCTAssertEqual(sut.state.timer.completedSessionCount, 0)
//        await sut.receive(.setAnimation(.startNextSession)) {
//            $0.animation = .startNextSession
//        }
//        //await sut.receive(.delegate(.didSaveTimer(sut.state.timer)))
//        await sut.send(.setAnimation(nil)) {
//            $0.animation = nil
//        }
//
////        // Short Break 1 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 1)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Work Session 2 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 1)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Short Break 2 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 2)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Work Session 3 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 2)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Short Break 3 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .shortBreak)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 3)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Work Session 4 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .longBreak)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 3)
////        await sut.receive(.setAnimation(.startNextSession)) {
////            $0.animation = .startNextSession
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
////
////        // Long Break 4 / 4
////        for _ in 0..<60 {
////            await clock.advance(by: .seconds(1))
////            await sut.receive(.timerTick) {
////                $0.timer.decrementTime()
////            }
////        }
////
////        // Animation
////        XCTAssertEqual(sut.state.timer.currentSession, .longBreak)
////        await clock.advance(by: .seconds(1))
////        await sut.receive(.timerTick) {
////            $0.timer.decrementTime()
////        }
////        XCTAssertEqual(sut.state.timer.currentSession, .work)
////        XCTAssertEqual(sut.state.timer.completedSessionCount, 0)
////        await sut.receive(.setAnimation(.finishedToPristine)) {
////            $0.animation = .finishedToPristine
////        }
////        await sut.send(.setAnimation(nil)) {
////            $0.animation = nil
////        }
//        await sut.send(.cancelEffect(.timer))
//    }
//}
