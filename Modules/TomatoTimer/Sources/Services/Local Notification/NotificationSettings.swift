import Foundation

struct NotificationSettings: Equatable {
    var workSound: NotificationSound
    var breakSound: NotificationSound
    var purchasedPro: Bool

    init(
        workSound: NotificationSound = .bell,
        breakSound: NotificationSound = .bell,
        purchasedPro: Bool = false
    ) {
        self.workSound = workSound
        self.breakSound = breakSound
        self.purchasedPro = purchasedPro
    }
}

extension Settings {
    var notificationSettings: NotificationSettings {
        return NotificationSettings(
            workSound: workSound,
            breakSound: breakSound,
            purchasedPro: purchasedPro
        )
    }
}
