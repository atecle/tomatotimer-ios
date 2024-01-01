import Foundation
import ComposableArchitecture
import ComposableUserNotifications

struct StopwatchTimerReducer: ReducerProtocol {

    // MARK: - Definitions

    enum CancelID: Hashable {
        case decrementTime
        case monitorTimer
        case monitorProject
    }

    enum Action: Equatable {
        case viewDidAppear
        case handleBackgroundMode
        case suspendBackgroundMode
        case setTimer(StopwatchTimer)
        case setProject(FocusProject)

        case toggleIsRunning
        case toggleSession
        case timerTick

        // Notifications
        case userNotifications(UserNotificationClient.DeletegateAction) // yes there is a typo in the lib
        case requestAuthorizationResponse(TaskResult<Bool>)
    }

    struct State: Equatable {
        var timer: StopwatchTimer
        var project: FocusProject
    }

    // MARK: - Properties

    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.continuousClock) var clock
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.stopwatchTimerClient) var stopwatchTimerClient

    // MARK: - Methods

    // swiftlint:disable:next function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewDidAppear:
            return .merge(
                monitor(state),
                decrementTimeEverySecond()
            )

        case .handleBackgroundMode:
            return .merge(
                decrementTimeEverySecond(),
                monitor(state)
            )

        case .suspendBackgroundMode:
            return .merge(
                EffectTask.cancel(id: CancelID.decrementTime),
                EffectTask.cancel(id: CancelID.monitorTimer),
                EffectTask.cancel(id: CancelID.monitorProject)
            )

        case let .setTimer(timer):
            state.timer = timer
            return .none

        case let .setProject(project):
            state.project = project
            if project.list.incompleteTaskCount == 0 && state.timer.isRunning {
                return .task {
                    .toggleIsRunning
                }
            }

            return .none

        case .toggleIsRunning:
            HapticFeedbackGenerator.impactOccurred(.medium)
            return .run { [state, focusProjectClient] _ in
                try await focusProjectClient.update(state.project.id) { project in
                    project.timer.isRunning.toggle()
                }
            }

        case .toggleSession:
            state.timer.toggleSession()
            return .run { [state, focusProjectClient] _ in
                try await focusProjectClient.update(state.project.id) { project in
                    project.timer.toggleSession()
                }
            }

        case .timerTick:
            guard state.timer.isRunning else {
                return .none
            }

            return .run { [state] _ in
                try await focusProjectClient.update(state.project.id) { project in
                    project.timerTick()
                }
            }

        case let .requestAuthorizationResponse(result):
            switch result {
            case .success:
                break
            case let .failure(error):
                fatalError("==== req auth response error \(error)")
            }

            return .none

        case let .userNotifications(.willPresentNotification(_, completion)):
            return .merge(
                .fireAndForget {
                    completion([.banner, .sound])
                }
            )

        case .userNotifications:
            return .none
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

    private func monitor(_ state: State) -> EffectTask<Action> {
        .merge(
            monitor(state.timer),
            monitor(state.project)
        )
    }

    private func monitor(_ timer: StopwatchTimer) -> EffectTask<Action> {
        stopwatchTimerClient.monitorWithID(timer.id)
            .catchToEffect().map { result in
                switch result {
                case let .success(timer):
                        return .setTimer(timer)
                case .failure:
                    fatalError()
                }
            }
            .cancellable(id: CancelID.monitorTimer)
    }

    private func monitor(_ project: FocusProject) -> EffectTask<Action> {
        focusProjectClient.monitorProjectWithID(project.id)
            .catchToEffect().map { result in
                switch result {
                case let .success(timer):
                        return .setProject(timer)
                case .failure:
                    fatalError()
                }
            }
            .cancellable(id: CancelID.monitorProject)
    }
}
