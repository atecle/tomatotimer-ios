import Foundation
import UIKit

struct Settings: Equatable {
    var id: UUID
    var timerConfig: TomatoTimerConfiguration = TomatoTimerConfiguration()
    var themeColor: UIColor = .defaultThemeColor
    var usingCustomColor = false
    var usingTodoList: Bool = false
    var workSound: NotificationSound = .bell
    var breakSound: NotificationSound = .bell
    var keepDeviceAwake: Bool = true
    var purchasedPro = false
    var isZenModeOn = false

    init(
        id: UUID = UUID(),
        timerConfig: TomatoTimerConfiguration = TomatoTimerConfiguration(),
        themeColor: UIColor = .defaultThemeColor,
        usingCustomColor: Bool = false,
        usingTodoList: Bool = false,
        purchasedPro: Bool = false,
        workSound: NotificationSound = .bell,
        breakSound: NotificationSound = .bell,
        keepDeviceAwake: Bool = true,
        isZenModeOn: Bool = false
    ) {
        self.id = id
        self.timerConfig = timerConfig
        self.themeColor = themeColor
        self.usingCustomColor = usingCustomColor
        self.usingTodoList = usingTodoList
        self.purchasedPro = purchasedPro
        self.workSound = workSound
        self.breakSound = breakSound
        self.keepDeviceAwake = keepDeviceAwake
        self.isZenModeOn = isZenModeOn
    }
}

extension Settings {
    static let `default`: Settings = Settings(
        timerConfig: TomatoTimerConfiguration(),
        themeColor: .defaultThemeColor,
        usingCustomColor: false,
        usingTodoList: false,
        purchasedPro: false,
        workSound: .bell,
        breakSound: .bell,
        isZenModeOn: false
    )
}
