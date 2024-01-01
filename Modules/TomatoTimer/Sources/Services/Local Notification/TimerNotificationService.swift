import Foundation
import UserNotifications

protocol TimerNotificationServiceProvider {
    var timerNotificationService: TimerNotificationServiceType { get }
}

struct LocalNotificationConfig: Equatable {
    var workSound: NotificationSound
    var breakSound: NotificationSound
}

protocol TimerNotificationServiceType {

    func localNotifications(
        for timer: StandardTimer,
        config: LocalNotificationConfig
    ) -> [LocalNotification]

    // Legacy
    func notificationsOnce(
        for timerState: TomatoTimer,
        notificationSettings: NotificationSettings
    ) -> [LocalNotification]
}

struct TimerNotificationService: TimerNotificationServiceType {

    // MARK: - TimerNotificationServiceType

    func localNotifications(
        for timer: StandardTimer,
        config: LocalNotificationConfig
    ) -> [LocalNotification] {
        return calculateLocalNotifications(for: timer, config: config)
    }

    // MARK: - Legacy

    func notificationsOnce(
        for timerState: TomatoTimer,
        notificationSettings: NotificationSettings
    ) -> [LocalNotification] {
        calculateLocalNotifications(for: timerState, settings: notificationSettings)
    }

    // MARK: - Private

    private func calculateLocalNotifications(for timer: StandardTimer, config: LocalNotificationConfig) -> [LocalNotification] {
        guard timer.isRunning else { return [] }

        let notificationCount = timer.config.sessionCount * 2
        let notificationIndex = (timer.completedSessionCount * 2) + (timer.currentSession == .work ? 0 : 1)
        var notifications: [LocalNotification] = []
        var interval: TimeInterval = 0
        let autostartWorkSession = timer.config.autostartWorkSession
        let autostartBreakSession = timer.config.autostartBreakSession
        //let autoStartNextSession = autostartWorkSession && autostartBreakSession
        for x in notificationIndex...notificationCount - 1 {
            if  x == notificationIndex {
                interval = TimeInterval(timer.timeLeftInSession)
                // print("===shuld get here \(interval) || \(notificationIndex) || \(notificationCount)")
                let currentSession: SessionType = notificationIndex % 2 == 0
                    ? .work
                    : (notificationIndex == notificationCount - 1 ? .longBreak : .shortBreak)
                let nextSession: SessionType = currentSession == .work ? (x == notificationCount - 2 ? .longBreak : .shortBreak) : .work
                let sound = nextSession == .work ? config.workSound : config.breakSound
                let title: String
                let body: String
                if currentSession == .longBreak {
                    title = String.pomodoroFinishedNotificationTitle
                    body = String.pomodoroFinishedNotificationBody
                } else {
                    title = String.notificationTitle(currentSession, nextSession)
                    body = String.notificationBodyV2(currentSession, nextSession, timer.config)
                }
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            } else if x == notificationCount - 1 {
                interval += TimeInterval(timer.config.longBreakLength)
                // print("==== but actually here \(interval) || \(notificationIndex) || \(notificationCount)")
                let title = String.pomodoroFinishedNotificationTitle
                let body = String.pomodoroFinishedNotificationBody
                let sound = config.workSound
                let n = LocalNotification(interval: interval, title: title, body: body, sound: sound)
                notifications.append(n)
            } else if x % 2 == 0 {
                interval += TimeInterval(timer.config.workSessionLength)
                // print("=== or maybe here \(interval) || \(notificationIndex) || \(notificationCount)")
                let nextSession: SessionType = (x == notificationCount - 2 ? .longBreak : .shortBreak)
                let sound = nextSession == .work ? config.workSound : config.breakSound
                let title = String.notificationTitle(.work, nextSession)
                let body = String.notificationBodyV2(.work, nextSession, timer.config)
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            } else {
                interval += TimeInterval(timer.config.shortBreakLength)
                // print("====== surely not here \(interval) || \(notificationIndex) || \(notificationCount)")
                let sound = config.workSound
                let title = String.notificationTitle(.shortBreak, .work)
                let body = String.notificationBodyV2(.shortBreak, .work, timer.config)
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            }

            if autostartWorkSession == false && x.isOdd {
                break
            }
            if autostartBreakSession == false && x.isEven {
                break
            }

        }

        return notifications
    }

    private func calculateLocalNotifications(for timer: TomatoTimer, settings: NotificationSettings) -> [LocalNotification] {

        let notificationCount = timer.sessionsCount * 2
        let notificationIndex = (timer.completedSessionsCount * 2) + (timer.currentSession == .work ? 0 : 1)
        var notifications: [LocalNotification] = []
        var interval: TimeInterval = 0
        let autostartWorkSession = timer.config.shouldAutostartNextWorkSession
        let autostartBreakSession = timer.config.shouldAutostartNextBreakSession
        let autoStartNextSession = autostartWorkSession && autostartBreakSession
        for x in notificationIndex...notificationCount - 1 {
            if  x == notificationIndex {
                interval = TimeInterval(timer.secondsLeftInCurrentSession)
                // print("===shuld get here \(interval) || \(notificationIndex) || \(notificationCount)")
                let currentSession: SessionType = notificationIndex % 2 == 0
                    ? .work
                    : (notificationIndex == notificationCount - 1 ? .longBreak : .shortBreak)
                let nextSession: SessionType = currentSession == .work ? (x == notificationCount - 2 ? .longBreak : .shortBreak) : .work
                let sound = settings.purchasedPro ? (nextSession == .work ? settings.workSound : settings.breakSound ): settings.workSound
                let title: String
                let body: String
                if currentSession == .longBreak {
                    title = String.pomodoroFinishedNotificationTitle
                    body = String.pomodoroFinishedNotificationBody
                } else {
                    title = String.notificationTitle(currentSession, nextSession)
                    body = String.notificationBody(currentSession, nextSession, timer.config)
                }
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            } else if x == notificationCount - 1 {
                interval += TimeInterval(timer.config.totalSecondsInLongBreakSession)
                // print("==== but actually here \(interval) || \(notificationIndex) || \(notificationCount)")
                let title = String.pomodoroFinishedNotificationTitle
                let body = String.pomodoroFinishedNotificationBody
                let sound = settings.workSound
                let n = LocalNotification(interval: interval, title: title, body: body, sound: sound)
                notifications.append(n)
            } else if x % 2 == 0 {
                interval += TimeInterval(timer.timerSessions.workSessionLength)
                // print("=== or maybe here \(interval) || \(notificationIndex) || \(notificationCount)")
                let nextSession: SessionType = (x == notificationCount - 2 ? .longBreak : .shortBreak)
                let sound = settings.purchasedPro ? (nextSession == .work ? settings.workSound : settings.breakSound ): settings.workSound
                let title = String.notificationTitle(.work, nextSession)
                let body = String.notificationBody(.work, nextSession, timer.config)
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            } else {
                interval += TimeInterval(timer.timerSessions.shortBreakLength)
                // print("====== surely not here \(interval) || \(notificationIndex) || \(notificationCount)")
                let sound = settings.workSound
                let title = String.notificationTitle(.shortBreak, .work)
                let body = String.notificationBody(.shortBreak, .work, timer.config)
                notifications.append(LocalNotification(interval: interval, title: title, body: body, sound: sound))
            }

            if settings.purchasedPro {
                if autostartWorkSession == false && x.isOdd {
                    break
                }
                if autostartBreakSession == false && x.isEven {
                    break
                }
            } else {
                if autoStartNextSession == false {
                    break
                }
            }

        }

        return notifications
    }
}
