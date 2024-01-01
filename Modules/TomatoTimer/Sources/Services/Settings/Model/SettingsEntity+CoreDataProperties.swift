//
//  SettingsEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/27/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension SettingsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsEntity> {
        let request = NSFetchRequest<SettingsEntity>(entityName: "SettingsEntity")
        request.sortDescriptors = SettingsEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var totalSecondsInWorkSession: Int64
    @NSManaged public var totalSecondsInShortBreakSession: Int64
    @NSManaged public var totalSecondsInLongBreakSession: Int64
    @NSManaged public var numberOfTimerSessions: Int64
    @NSManaged public var shouldAutostartNextWorkSession: Bool
    @NSManaged public var shouldAutostartNextBreakSession: Bool
    @NSManaged public var themeColorHexString: String?
    @NSManaged public var usingCustomColor: Bool
    @NSManaged public var usingTodoList: Bool
    @NSManaged public var workSound: Int64
    @NSManaged public var breakSound: Int64
    @NSManaged public var purchasedPro: Bool
    @NSManaged public var isZenModeOn: Bool
    @NSManaged public var keepDeviceAwake: Bool

}

extension SettingsEntity: Identifiable {

}
