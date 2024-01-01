import Foundation
import Clocks
import ComposableArchitecture
import ComposableUserNotifications
import UserNotifications
import UIKit

// swiftlint:disable line_length

struct TomatoTimerReducer: ReducerProtocol {

    // MARK: - Definitions

    private enum CancelID {
        case timer
    }

    private enum Constant {
        static let timerTick: Duration = .seconds(1)
    }

    struct State: Equatable {
        var animation: Animation?
        var tomatoTimer: TomatoTimer = .init()
        var authorizedNotifications: Bool { notificationAuthorizationStatus != .denied }
        var notificationAuthorizationStatus = UNAuthorizationStatus.notDetermined
        var scheduledNotifications: [LocalNotification] = []
        var settings: Settings = .init()
    }

    enum Action: Equatable {

        // Load
        case viewDidAppear
        case loadTimer(TomatoTimer)
        case setTimeElapsed(Int)
        case loadSettings(Settings)
        case checkNotificationStatus
        case setNotificationAuthorizationStatus(UNAuthorizationStatus)

        // Timer mutations
        case toggleIsRunning
        case restartTimer
        case restartSession
        case complete
        case decrementTime
        case setAnimation(Animation?)

        // Notifications
        case userNotifications(UserNotificationClient.DeletegateAction) // yes there is a typo in the lib
        case requestAuthorizationResponse(TaskResult<Bool>)
        case removeDeliveredNotification(String)
    }

    enum Animation: Equatable {
        case pristineToStarted
        case startedToPristine(secondsLeft: Int, totalSeconds: Int)
        case finishedToPristine
        case refill(secondsLeft: Int, totalSeconds: Int)
        case completeAndContinue(secondsLeft: Int, totalSeconds: Int)
        case startNextSession
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date

    // MARK: - Methods

    // swiftlint:disable function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {

        switch action {

        case .viewDidAppear:
            return .merge(
                fetch(),
                receiveUserNotificationDelegateActions(),
                checkNotificationPermissions(),
                decrementTimeEverySecond()
            )

        case let .loadTimer(timer):
            state.tomatoTimer = timer
            return .none

        case let .loadSettings(settings):
            state.settings = settings
            return .none

        case let .setTimeElapsed(elapsed):
            guard state.tomatoTimer.isRunning else { return .none }
            state.tomatoTimer.setTimeElapsed(elapsed)
            return saveTimerToDisk(state.tomatoTimer)

        case .toggleIsRunning:
            guard state.animation == nil, state.authorizedNotifications else {
                return .none
            }

            var effects: [EffectTask<Action>] = []

            if !state.tomatoTimer.hasBegun && !state.tomatoTimer.isRunning {
               effects.append(.init(value: .setAnimation(.pristineToStarted)))
            }

            state.tomatoTimer.isRunning.toggle()

            state.tomatoTimer.isRunning
            ? effects.append(contentsOf: [
                decrementTimeEverySecond(),
                requestNotificationPermissionIfNeeded(),
                rescheduleNotifications(&state)
            ])
            : effects.append(contentsOf: [
                saveTimerToDisk(state.tomatoTimer),
                EffectTask.cancel(id: CancelID.timer),
                cancelNotifications(&state)
            ])

            HapticFeedbackGenerator.impactOccurred(.medium)
            return .merge(effects)

        case .decrementTime:
            // Needed for end of session with autostart off, or cycle completion.
            guard state.tomatoTimer.isRunning else {
                return .merge(
                    EffectTask.cancel(id: CancelID.timer)
                )
            }

            print("===================== timer tick")
            state.tomatoTimer.decrementTime()
            var effects: [EffectTask<Action>] = [saveTimerToDisk(state.tomatoTimer)]

            if !state.tomatoTimer.hasBegun && state.tomatoTimer.isRunning {
                effects.append(.init(value: .setAnimation(.startNextSession)))
            } else if !state.tomatoTimer.hasBegun {
                effects.append(.init(value: .setAnimation(.finishedToPristine)))
            }

            if state.tomatoTimer.secondsLeftInCurrentSession == 20 {
                // An *ancient* hack to make sure notifications are as precise as possible
                effects.append(rescheduleNotifications(&state))
            }

            return .merge(effects)

        case .restartTimer:
            let animation: EffectTask<Action> = state.tomatoTimer.hasBegun
            ? .init(value: .setAnimation(.startedToPristine(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            : .none
            state.tomatoTimer.restartTimer()
            return EffectTask.merge(
                animation,
                saveTimerToDisk(state.tomatoTimer),
                EffectTask.cancel(id: CancelID.timer),
                cancelNotifications(&state)
            )

        case .restartSession:
            let animation: EffectTask<Action>
            if state.tomatoTimer.hasBegun && state.tomatoTimer.isRunning {
                animation = .init(value: .setAnimation(.refill(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            } else if state.tomatoTimer.hasBegun {
                animation = .init(value: .setAnimation(.startedToPristine(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            } else {
                animation = .none
            }
            state.tomatoTimer.restartSession()
            return .merge(
                animation,
                saveTimerToDisk(state.tomatoTimer),
                rescheduleOrCancelNotifications(&state)
            )

        case .complete:
            let animation: EffectTask<Action>
            if state.tomatoTimer.hasBegun && state.tomatoTimer.isRunning && state.tomatoTimer.isLastSession {
                animation = .init(value: .setAnimation(.startedToPristine(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            } else if state.tomatoTimer.hasBegun && state.tomatoTimer.isRunning {
                animation = .init(value: .setAnimation(.completeAndContinue(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            } else if state.tomatoTimer.hasBegun {
                animation = .init(value: .setAnimation(.startedToPristine(secondsLeft: state.tomatoTimer.secondsLeftInCurrentSession, totalSeconds: state.tomatoTimer.totalSecondsInCurrentSession)))
            } else {
                animation = .none
            }
            state.tomatoTimer.complete()
            return .merge(
                animation,
                saveTimerToDisk(state.tomatoTimer),
                rescheduleOrCancelNotifications(&state)
            )

        case let .setAnimation(animation):
            state.animation = animation

            return .none

        case let .requestAuthorizationResponse(result):
            switch result {
            case let .success(authorized):
                print("==== notifications authorized: \(authorized)")
                let previousAuthStatus = state.notificationAuthorizationStatus
                state.notificationAuthorizationStatus = authorized ? .authorized : .denied
                if !authorized {
                    return .run { send in
                        await send(.restartTimer)
                    }
                } else if previousAuthStatus == .notDetermined && state.notificationAuthorizationStatus == .authorized {
                    return rescheduleNotifications(&state)
                }
            case .failure:
                state.notificationAuthorizationStatus = .denied
                return .none
            }

            return .none

        case let .userNotifications(.willPresentNotification(notification, completion)):
            return .merge(
                .fireAndForget {
                    completion([.banner, .sound])
                },
                EffectTask(value: .removeDeliveredNotification(notification.request.identifier))
            )

        case let .removeDeliveredNotification(id):
            state.scheduledNotifications.removeAll { $0.id == id }
            return .none

        case .checkNotificationStatus:
            return checkNotificationPermissions()

        case let .setNotificationAuthorizationStatus(status):
            state.notificationAuthorizationStatus = status
            return .none

        case .userNotifications:
            return .none
        }
    }

    // MARK: Helpers

    func decrementTimeEverySecond() -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.timer)
            .concatenate(
                with:
                        .run { send in
                            for await _ in self.clock.timer(interval: .seconds(1)) {
                                await send(.decrementTime)
                            }
                        }
                    .cancellable(id: CancelID.timer)
            )

    }

    func saveTimerToDisk(_ timer: TomatoTimer) -> EffectTask<Action> {
        return .run { _ in
            try await services.timerService.update(timer)
        }
    }

    func requestNotificationPermissionIfNeeded() -> EffectTask<Action> {
        .run { send in
            await send(.requestAuthorizationResponse(
                TaskResult {
                    try await self.userNotifications.requestAuthorization([.alert, .sound])
                }
            ))
        }
    }

    func receiveUserNotificationDelegateActions() -> EffectTask<Action> {
        .run { send in
            for await event in self.userNotifications.delegate() {
                await send(.userNotifications(event))
            }
        }
    }

    func rescheduleOrCancelNotifications(_ state: inout State) -> EffectTask<Action> {
        guard state.tomatoTimer.isRunning else {
            return cancelNotifications(&state)
        }

        return rescheduleNotifications(&state)
    }

    func rescheduleNotifications(_ state: inout State) -> EffectTask<Action> {
        return .merge(
            cancelNotifications(&state),
            scheduleNotifications(&state)
        )
    }

    func cancelNotifications(_ state: inout State) -> EffectTask<Action> {
        print("================== Cancelling Notifications")
        state.scheduledNotifications = []
        return .run { _ in
            await self.userNotifications.removeAllPendingNotificationRequests()
        }
    }

    func scheduleNotifications(_ state: inout State) -> EffectTask<Action> {
        let scheduledNotifications = services.timerNotificationService.notificationsOnce(
            for: state.tomatoTimer,
            notificationSettings: state.settings.notificationSettings
        )
        state.scheduledNotifications = scheduledNotifications
        print("================= Scheduling notifications")
        for notif in scheduledNotifications {
            print("====================== Scheduling notification with title \(notif.title) || Interval \(notif.interval)")
        }
        return .run { _ in
            await self.userNotifications.removeAllPendingNotificationRequests()
            for notification in scheduledNotifications.map(\.toUNNotification) {
                try await self.userNotifications.add(notification)
            }
        }
    }

    func fetch() -> EffectTask<Action> {
        return .merge(
            services.timerService.timer().catchToEffect()
            .map {
                switch $0 {
                case let .success(timer):
                    return .loadTimer(timer)
                default:
                    fatalError()
                }
            },
            services.settingsService.settings().catchToEffect()
                .map {
                    switch $0 {
                    case let .success(settings):
                        return .loadSettings(settings)
                    default:
                        fatalError()
                    }
                }
        )
    }

    func checkNotificationPermissions() -> EffectTask<Action> {
        .run { send in
            let result = (await userNotifications.notificationSettings()).authorizationStatus()
            await send(.setNotificationAuthorizationStatus(result))
        }
    }

}
