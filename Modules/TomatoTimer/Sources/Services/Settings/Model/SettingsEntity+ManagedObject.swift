import Foundation
import UIKit
import CoreData

extension SettingsEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> Settings? {
        return Settings(entity: self)
    }

    func update(from nonManagedObject: Settings, context: NSManagedObjectContext) {
        id = nonManagedObject.id
        totalSecondsInWorkSession = Int64(nonManagedObject.timerConfig.totalSecondsInWorkSession)
        totalSecondsInShortBreakSession = Int64(nonManagedObject.timerConfig.totalSecondsInShortBreakSession)
        totalSecondsInLongBreakSession = Int64(nonManagedObject.timerConfig.totalSecondsInLongBreakSession)
        numberOfTimerSessions = Int64(nonManagedObject.timerConfig.numberOfTimerSessions)

        shouldAutostartNextWorkSession = nonManagedObject.timerConfig.shouldAutostartNextWorkSession
        shouldAutostartNextBreakSession = nonManagedObject.timerConfig.shouldAutostartNextBreakSession
        themeColorHexString = nonManagedObject.themeColor.hexString()

        usingCustomColor = nonManagedObject.usingCustomColor
        usingTodoList = nonManagedObject.usingTodoList

        workSound = Int64(nonManagedObject.workSound.rawValue)
        breakSound = Int64(nonManagedObject.breakSound.rawValue)
        purchasedPro = nonManagedObject.purchasedPro

        isZenModeOn = nonManagedObject.isZenModeOn
        keepDeviceAwake = nonManagedObject.keepDeviceAwake
    }

}

extension Settings {

    init?(
        entity: SettingsEntity
    ) {
        guard
            let id = entity.id,
            let workSound = NotificationSound(rawValue: Int(entity.workSound)),
            let breakSound = NotificationSound(rawValue: Int(entity.breakSound))
        else { return nil }

        self.init(
            id: id,
            timerConfig: TomatoTimerConfiguration(
                totalSecondsInWorkSession: Int(entity.totalSecondsInWorkSession),
                totalSecondsInShortBreakSession: Int(entity.totalSecondsInShortBreakSession),
                totalSecondsInLongBreakSession: Int(entity.totalSecondsInLongBreakSession),
                numberOfTimerSessions: Int(entity.numberOfTimerSessions),
                shouldAutostartNextWorkSession: entity.shouldAutostartNextWorkSession,
                shouldAutostartNextBreakSession: entity.shouldAutostartNextBreakSession
            ),
            themeColor: UIColor(entity.themeColorHexString ?? UIColor.appPomodoroRed.hexString()),
            usingCustomColor: entity.usingCustomColor,
            usingTodoList: entity.usingTodoList,
            purchasedPro: entity.purchasedPro,
            workSound: workSound,
            breakSound: breakSound,
            keepDeviceAwake: entity.keepDeviceAwake,
            isZenModeOn: entity.isZenModeOn
        )
    }
}
