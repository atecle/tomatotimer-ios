//
//  FocusProjectEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension FocusProjectEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusProjectEntity> {
        let request = NSFetchRequest<FocusProjectEntity>(entityName: "FocusProjectEntity")
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var themeColorHexString: String?
    @NSManaged public var title: String?
    @NSManaged public var list: FocusListEntity?
    @NSManaged public var recurrence: FocusProjectRecurrenceEntity?
    @NSManaged public var recurrenceTemplate: FocusProjectRecurrenceEntity?
    @NSManaged public var timer: TimerEntity?
    @NSManaged public var activityGoals: NSSet?

}

// MARK: Generated accessors for activityGoals
extension FocusProjectEntity {

    @objc(addActivityGoalsObject:)
    @NSManaged public func addToActivityGoals(_ value: ActivityGoalEntity)

    @objc(removeActivityGoalsObject:)
    @NSManaged public func removeFromActivityGoals(_ value: ActivityGoalEntity)

    @objc(addActivityGoals:)
    @NSManaged public func addToActivityGoals(_ values: NSSet)

    @objc(removeActivityGoals:)
    @NSManaged public func removeFromActivityGoals(_ values: NSSet)

}

extension FocusProjectEntity: Identifiable {

}
