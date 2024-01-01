import Foundation
import UserNotifications

struct LocalNotification: Equatable, Identifiable {
    let id = UUID().uuidString
    let interval: TimeInterval
    let title: String
    let body: String
    let sound: NotificationSound
    let created = Date()
    var scheduledDate: Date {
        created.addingTimeInterval(interval)
    }

    var simple: SimpleLocalNotification {
        .init(
            interval: interval,
            sound: sound
        )
    }
}

struct SimpleLocalNotification: Equatable {
    let interval: TimeInterval
    let sound: NotificationSound
}

extension LocalNotification {
    var toUNNotification: UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.userInfo = ["creation_date": Date()]
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(sound.description).m4r"))
        let interval = max(self.interval, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
