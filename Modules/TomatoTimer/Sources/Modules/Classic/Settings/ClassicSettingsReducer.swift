import Foundation
import ComposableArchitecture
import UIKit

struct ClassicSettingsReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {

        case viewDidAppear

        // Timer
        case setWorkLength(Int)
        case setShortBreakLength(Int)
        case setLongBreakLength(Int)
        case setNumberOfSessions(Int)

        // Theme Color
        case setThemeColor(UIColor)
        case setCustomThemeColor(UIColor)

        // Notifications
        case setNotificationSound(NotificationSound)
        case setWorkSound(NotificationSound?)
        case setBreakSound(NotificationSound?)

        // Additional
        case setAutostartNextSession(Bool)
        case setAutostartNextWorkSession(Bool)
        case setAutostartNextBreakSession(Bool)
        case setKeepDeviceAwake(Bool)
        case setUseTodoList(Bool)

        // Other
        case playNotificationSound(NotificationSound)
        case dismissButtonPressed
        case unlockMoreFeaturesButtonPressed
        case howToUseButtonPressed
        case reviewButtonPressed
        case contactButtonPressed

        case setClassicMode(Bool)

        // Child
        case proUpgrade(PresentationAction<ProUpgradeReducer.Action>)
        case onboarding(PresentationAction<ClassicOnboardingReducer.Action>)
    }

    struct State: Equatable {
        var timer: TomatoTimer
        var settings: Settings
        var classicMode: Bool = true
        var scheduledNotifications: [LocalNotification] = []

        @PresentationState var onboarding: ClassicOnboardingReducer.State?
        @PresentationState var proUpgrade: ProUpgradeReducer.State?
    }

    // MARK: - Properties

    @Dependency(\.openURL) var openURL
    @Dependency(\.uiApplication) var uiApplication
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    // MARK: - Methods

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                state.classicMode = UserDefaults.standard.bool(forKey: "classic_mode")
                return .none

            case let .setClassicMode(isOn):
                state.classicMode = isOn
                UserDefaults.standard.set(isOn, forKey: "classic_mode")
                return .none

            case let .proUpgrade(.presented(.delegate(.purchasedPro(settings)))):
                state.settings = settings
                return .none

            case .proUpgrade, .onboarding:
                return .none

            case let .setWorkLength(length):
                state.settings.timerConfig.totalSecondsInWorkSession = length * 60
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setShortBreakLength(length):
                state.settings.timerConfig.totalSecondsInShortBreakSession = length * 60
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setLongBreakLength(length):
                state.settings.timerConfig.totalSecondsInLongBreakSession = length * 60
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setNumberOfSessions(length):
                state.settings.timerConfig.numberOfTimerSessions = length
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setThemeColor(color):
                state.settings.themeColor = color
                state.settings.usingCustomColor = false
                return saveSettingsToDisk(state.settings)

            case let .setCustomThemeColor(color):
                let color = UIColor((try? color.hexStringThrows()) ?? UIColor.white.hexString())
                state.settings.themeColor = color
                state.settings.usingCustomColor = true
                return saveSettingsToDisk(state.settings)

            case let .setNotificationSound(sound):
                state.settings.workSound = sound
                state.settings.breakSound = sound
                return .merge(
                    saveSettingsToDisk(state.settings),
                    rescheduleOrCancelNotifications(&state),
                    EffectTask(value: .playNotificationSound(sound))
                )

            case let .setWorkSound(sound):
                guard let sound else { return .none }
                state.settings.workSound = sound
                return .merge(
                    saveSettingsToDisk(state.settings),
                    rescheduleOrCancelNotifications(&state),
                    EffectTask(value: .playNotificationSound(sound))
                )

            case let .setBreakSound(sound):
                guard let sound else { return .none }
                state.settings.breakSound = sound
                return .merge(
                    saveSettingsToDisk(state.settings),
                    rescheduleOrCancelNotifications(&state),
                    EffectTask(value: .playNotificationSound(sound))
                )

            case let .setAutostartNextSession(autostart):
                state.settings.timerConfig.shouldAutostartNextWorkSession = autostart
                state.settings.timerConfig.shouldAutostartNextBreakSession = autostart
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setAutostartNextWorkSession(autostart):
                state.settings.timerConfig.shouldAutostartNextWorkSession = autostart
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setAutostartNextBreakSession(autostart):
                state.settings.timerConfig.shouldAutostartNextBreakSession = autostart
                state.timer.update(with: state.settings.timerConfig)
                return .merge(
                    saveSettingsToDisk(state.settings),
                    saveTimerToDisk(state.timer),
                    rescheduleOrCancelNotifications(&state)
                )

            case let .setKeepDeviceAwake(keepAwake):
                state.settings.keepDeviceAwake = keepAwake
                uiApplication.isIdleTimerDisabled = keepAwake
                return .merge(
                    saveSettingsToDisk(state.settings)
                )

            case let .setUseTodoList(useTodoList):
                state.settings.usingTodoList = useTodoList
                return saveSettingsToDisk(state.settings)

            case let .playNotificationSound(sound):
                services.audioPlayer.playNotificationSound(sound)
                return .none

            case .unlockMoreFeaturesButtonPressed:
                state.proUpgrade = ProUpgradeReducer.State(
                    settings: state.settings
                )
                return .none

            case .howToUseButtonPressed:
                state.onboarding = ClassicOnboardingReducer.State()
                return .none

            case .reviewButtonPressed:
                guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1453228755") else { return  .none }

                return .run { [openURL] _ in
                    await openURL(url)
                }

            case .contactButtonPressed:
                guard
                    let urlString = "mailto:support@tomatotimerapp.com"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else { return .none }

                return .run { _ in
                    await openURL(url)
                }

            case .dismissButtonPressed:
                return .fireAndForget { await self.dismiss() }
            }
        }
        .ifLet(\.$onboarding, action: /Action.onboarding) {
            ClassicOnboardingReducer()
        }
        .ifLet(\.$proUpgrade, action: /Action.proUpgrade) {
            ProUpgradeReducer()
        }
    }

    // MARK: - Helper

    func saveSettingsToDisk(_ settings: Settings) -> EffectTask<Action> {
        .run { _ in
            try await services.settingsService.update(settings)
        }
        // services.settingsService.save(settings).publisher.fireAndForget()
    }

    func saveTimerToDisk(_ timer: TomatoTimer) -> EffectTask<Action> {
        .run { _ in
            try await services.timerService.update(timer)
        }
    }

    func rescheduleOrCancelNotifications(_ state: inout State) -> EffectTask<Action> {
        guard state.timer.isRunning else {
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
        state.scheduledNotifications = []
        print("======================= Cancelling notifications")
        return .run { _ in
            await self.userNotifications.removeAllPendingNotificationRequests()
        }
    }

    func scheduleNotifications(_ state: inout State) -> EffectTask<Action> {
        let scheduledNotifications = services.timerNotificationService.notificationsOnce(
            for: state.timer,
            notificationSettings: state.settings.notificationSettings
        )
        print("======================= Scheduling notifications")
        state.scheduledNotifications = scheduledNotifications
        return .run { _ in
            for notification in scheduledNotifications.map(\.toUNNotification) {
                try await self.userNotifications.add(notification)
            }
        }
    }

}
