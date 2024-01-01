import Foundation
import ComposableArchitecture
import UIKit
import ComposableUserNotifications

struct StandardTimerReducer: ReducerProtocol {

    // MARK: - Definitions

    enum ThrottleID: Hashable {
        case notifications
    }

    enum CancelID: Hashable {
        case decrementTime
        case monitorTimer
        case monitorProject
        case notifications
    }

    enum Action: Equatable {
        // Load
        case onAppear
        case setTimer(StandardTimer)
        case setProject(FocusProject)
        case setNotificationAuthorizationStatus(UNAuthorizationStatus)
        case handleBackgroundMode
        case suspendBackgroundMode

        // Timer Mutations
        case toggleIsRunning
        case timerTick
        case setAnimation(StandardTimerAnimation?)

        // Notifications
        case userNotifications(UserNotificationClient.DeletegateAction) // yes there is a typo in the lib
        case requestAuthorizationResponse(TaskResult<Bool>)
        case removeDeliveredNotification(String)
        case checkNotificationStatus
    }

    struct State: Equatable {
        var timer: StandardTimer
        var project: FocusProject
        fileprivate var list: FocusList { project.list }
        var incompleteTaskCount: Int { list.incompleteTaskCount }
        var animation: StandardTimerAnimation?
        var authorizedNotifications: Bool { notificationAuthorizationStatus != .denied }
        var notificationAuthorizationStatus = UNAuthorizationStatus.notDetermined
        var scheduledNotifications: [LocalNotification] = []
    }

    // MARK: - Properties

    // MARK: Dependencies

    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date
    @Dependency(\.services) var services
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.standardTimerClient) var standardTimerClient
    @Dependency(\.mainQueue) var mainQueue

    // MARK: - Methods

    // swiftlint:disable function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        case .handleBackgroundMode:
            print("============== Handling background mode")
            return .merge(
                decrementTimeEverySecond(),
                setNotificationPermissions(),
                receiveUserNotificationDelegateActions(),
                monitorTimer(state.timer),
                monitorProject(state.project),
                rescheduleNotifications(&state, askForPermission: false)
            )
        case .suspendBackgroundMode:
            print("============== Suspending background mode")
            return .merge(
                EffectTask.cancel(id: CancelID.decrementTime),
                EffectTask.cancel(id: CancelID.monitorTimer),
                EffectTask.cancel(id: CancelID.monitorProject),
                EffectTask.cancel(id: CancelID.notifications),
                cancelNotifications(&state)
            )

        case .onAppear:
            return .merge(
                decrementTimeEverySecond(),
                setNotificationPermissions(),
                receiveUserNotificationDelegateActions(),
                monitorTimer(state.timer),
                monitorProject(state.project),
                rescheduleNotifications(&state, askForPermission: false)
            )

        case let .setTimer(timer):
            let previous = state
            state.timer = timer
            var effects: [EffectTask<Action>] = []
            if state.animation == nil {
                effects.append(
                    .init(value: .setAnimation(
                        computeAnimation(
                            previous: previous,
                            current: state
                        )
                    ))
                )
            }

            if previous.timer.config != state.timer.config {
                effects.append(rescheduleOrCancelNotifications(&state))
            }

            return .merge(effects)

        case let .setProject(project):
            state.project = project
            return .none

        case let .setNotificationAuthorizationStatus(status):
            state.notificationAuthorizationStatus = status
            return .none

            // Timer Mutations

        case .toggleIsRunning:
            // So you can't toggle is running while animation is in progress
            guard state.animation == nil else {
                return .none
            }

            HapticFeedbackGenerator.impactOccurred(.medium)
            return  .run { [focusProjectClient, state] _ in
                try await focusProjectClient.update(state.project.id) { project in
                    project.timer.isRunning.toggle()
                }
            }

        case .timerTick:
            // Needed for end of session with autostart off, or cycle completion.
            guard state.timer.isRunning else {
                if !state.scheduledNotifications.isEmpty {
                    return cancelNotifications(&state)
                } else {
                    return .none
                }
            }

            var effects: [EffectTask<Action>] = []
            // Schedule notifications if needed
            if state.scheduledNotifications.isEmpty {
                effects.append(rescheduleNotifications(&state))
            }

            // Do hax
            if state.timer.timeLeftInSession == 5 {
                // An *ancient* hack to make sure notifications are as precise as possible
                effects.append(rescheduleNotifications(&state))
            }

            print("================= timer ticked")
            return .merge(effects).concatenate(with: .run { [state] _ in
                do {
                    try await focusProjectClient.update(state.project.id) { project in
                        project.timerTick()
                    }
                } catch {
                    print(error)
                }
            })

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
                    return .none
                    //                    return .run { send in
                    //                        await send(.restartTimer)
                    //                    }
                } else if previousAuthStatus == .notDetermined && state.notificationAuthorizationStatus == .authorized {
                    return rescheduleNotifications(&state)
                }
            case .failure:
                state.notificationAuthorizationStatus = .denied
                return .none
            }

            return .none

        case .checkNotificationStatus:
            return setNotificationPermissions()

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

        case .userNotifications:
            return .none
        }
    }

    // MARK: - Helper

    // Timer / Notifications

    private func decrementTimeEverySecond() -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.decrementTime)
            .concatenate(
                with: .run { send in
                    for await _ in self.clock.timer(interval: .milliseconds(1000)) {
                        await send(.timerTick)
                    }
                }
            )
            .cancellable(id: CancelID.decrementTime)
    }

    private func setNotificationPermissions() -> EffectTask<Action> {
        .run { send in
            let result = (await userNotifications.notificationSettings()).authorizationStatus()
            await send(.setNotificationAuthorizationStatus(result))
        }
    }

    private func requestNotificationPermissions() -> EffectTask<Action> {
        .run { send in
            await send(.requestAuthorizationResponse(
                TaskResult {
                    try await self.userNotifications.requestAuthorization([.alert, .sound])
                }
            ))
        }
    }

    private func rescheduleOrCancelNotifications(_ state: inout State) -> EffectTask<Action> {
        guard state.timer.isRunning else {
            return cancelNotifications(&state)
        }

        return rescheduleNotifications(&state)
    }

    private func rescheduleNotifications(_ state: inout State, askForPermission: Bool = true) -> EffectTask<Action> {
        return .merge(
            cancelNotifications(&state),
            scheduleNotifications(&state, askForPermission: askForPermission)
        )
    }

    private func cancelNotifications(_ state: inout State) -> EffectTask<Action> {
        state.scheduledNotifications = []
        print("=============== Cancelling Notifications By ID")
        return .run { _ in
            await self.userNotifications.removeAllPendingNotificationRequests()
        }
    }

    private func receiveUserNotificationDelegateActions() -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.notifications)
            .concatenate(with: .run { send in
                for await event in self.userNotifications.delegate() {
                    await send(.userNotifications(event))
                }
            }.cancellable(id: CancelID.notifications))
    }

    private func scheduleNotifications(_ state: inout State, askForPermission: Bool = true) -> EffectTask<Action> {
        let requestNotificationPermissionsIfNeeded: EffectTask<Action>
        if state.notificationAuthorizationStatus == .notDetermined, askForPermission {
            requestNotificationPermissionsIfNeeded = requestNotificationPermissions()
        } else {
            requestNotificationPermissionsIfNeeded = .none
        }

        let scheduledNotifications = services.timerNotificationService.localNotifications(
            for: state.timer,
            config: LocalNotificationConfig(
                workSound: state.timer.config.workSound,
                breakSound: state.timer.config.breakSound
            )
        )
        state.scheduledNotifications = scheduledNotifications
        for notif in state.scheduledNotifications {
            print("=============== Scheduling notification | Interval \(notif.interval) | Title \(notif.title) | Sound \(notif.sound.description)")
        }
        return requestNotificationPermissionsIfNeeded.concatenate(with: .run { _ in
            for notification in scheduledNotifications.map(\.toUNNotification) {
                try await self.userNotifications.add(notification)
            }
        })
        .eraseToEffect()
    }

    // Animation

    func computeAnimation(
        previous: State,
        current: State
    ) -> StandardTimerAnimation? {
        if (previous.timer.isPristine && current.timer.hasBegun)
            || (!previous.timer.hasBegun && !previous.timer.isRunning && current.timer.isRunning && !current.timer.hasBegun) {
            return .pristineToStarted
        } else if
            (!previous.timer.isPristine && current.timer.isPristine) ||
                ((previous.timer.isRunning && previous.timer.hasBegun) && !current.timer.isRunning && !current.timer.hasBegun) {
            if current.timer.hasBegun {
                return .startedToPristine(
                    secondsLeft: current.timer.timeLeftInSession,
                    totalSeconds: current.timer.sessionLength
                )
            } else {
                return .finishedToPristine
            }
        } else if (previous.timer.isRunning && previous.timer.hasBegun) && current.timer.isRunning && !current.timer.hasBegun {

            if previous.timer.currentSession == current.timer.currentSession {
                return .refill(
                    secondsLeft: current.timer.timeLeftInSession,
                    totalSeconds: current.timer.sessionLength
                )
            } else if previous.timer.timeLeftInSession == 0, current.timer.timeLeftInSession == current.timer.sessionLength {
                return .startNextSession
            } else {
                return .completeAndContinue(
                    secondsLeft: current.timer.timeLeftInSession,
                    totalSeconds: current.timer.sessionLength
                )
            }
        }

        return nil
    }

    func monitorTimer(_ timer: StandardTimer) -> EffectTask<Action> {
        return standardTimerClient.monitorWithID(timer.id)
            .catchToEffect().map { result in
                switch result {
                case let .success(timer):
                    return .setTimer(timer)
                default:
                    fatalError()
                }
            }
    }

    func monitorProject(_ project: FocusProject) -> EffectTask<Action> {
        focusProjectClient.monitorProjectWithID(project.id)
            .catchToEffect().map { result in
                switch result {
                case let .success(project):
                    return .setProject(project)
                default:
                    fatalError()
                }
            }
    }
}
