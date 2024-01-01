//
//  StandardTimerEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension StandardTimerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StandardTimerEntity> {
        let request = NSFetchRequest<StandardTimerEntity>(entityName: "StandardTimerEntity")
        request.sortDescriptors = StandardTimerEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var isRunning: Bool
    @NSManaged public var timeLeftInSession: Int64
    @NSManaged public var currentSession: Int64
    @NSManaged public var completedSessionCount: Int64
    @NSManaged public var totalWorkTime: Int64
    @NSManaged public var totalBreakTime: Int64
    @NSManaged public var isComplete: Bool
    @NSManaged public var wasStarted: Bool
    @NSManaged public var workSessionLength: Int64
    @NSManaged public var shortBreakLength: Int64
    @NSManaged public var longBreakLength: Int64
    @NSManaged public var sessionCount: Int64
    @NSManaged public var autostartWorkSession: Bool
    @NSManaged public var autostartBreakSession: Bool
    @NSManaged public var workSound: Int64
    @NSManaged public var breakSound: Int64

}
