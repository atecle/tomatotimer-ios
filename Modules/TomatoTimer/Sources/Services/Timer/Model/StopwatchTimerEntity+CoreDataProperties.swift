//
//  StopwatchTimerEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension StopwatchTimerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StopwatchTimerEntity> {
        let request = NSFetchRequest<StopwatchTimerEntity>(entityName: "StopwatchTimerEntity")
        request.sortDescriptors = StopwatchTimerEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var currentSession: Int64
    @NSManaged public var isRunning: Bool
    @NSManaged public var isComplete: Bool
    @NSManaged public var hasBegun: Bool
    @NSManaged public var workTime: Int64
    @NSManaged public var breakTime: Int64
    @NSManaged public var elapsedWorkTime: Int64
    @NSManaged public var elapsedBreakTime: Int64

}
