//
//  TomatoTimerEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/25/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension TomatoTimerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TomatoTimerEntity> {
        let request = NSFetchRequest<TomatoTimerEntity>(entityName: "TomatoTimerEntity")
        request.sortDescriptors = TomatoTimerEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isRunning: Bool
    @NSManaged public var timeLeftInCurrentSession: Int64
    @NSManaged public var workSessionLength: Int64
    @NSManaged public var shortBreakLength: Int64
    @NSManaged public var longBreakLength: Int64
    @NSManaged public var numberOfTimerSessions: Int64
    @NSManaged public var completedSessionsCount: Int64
    @NSManaged public var shouldAutostartNextWorkSession: Bool
    @NSManaged public var shouldAutostartNextBreakSession: Bool
    @NSManaged public var currentSession: Int64
    @NSManaged public var creationDate: Date?

}

extension TomatoTimerEntity: Identifiable {

}
