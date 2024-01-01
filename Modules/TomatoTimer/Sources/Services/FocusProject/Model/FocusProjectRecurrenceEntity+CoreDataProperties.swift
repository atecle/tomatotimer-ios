//
//  FocusProjectRecurrenceEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/11/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension FocusProjectRecurrenceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusProjectRecurrenceEntity> {
        let request = NSFetchRequest<FocusProjectRecurrenceEntity>(entityName: "FocusProjectRecurrenceEntity")
        request.sortDescriptors = FocusProjectRecurrenceEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var repeatingDays: NSSet?
    @NSManaged public var template: FocusProjectEntity?
    @NSManaged public var instances: NSSet?

}

// MARK: Generated accessors for instances
extension FocusProjectRecurrenceEntity {

    @objc(addInstancesObject:)
    @NSManaged public func addToInstances(_ value: FocusProjectEntity)

    @objc(removeInstancesObject:)
    @NSManaged public func removeFromInstances(_ value: FocusProjectEntity)

    @objc(addInstances:)
    @NSManaged public func addToInstances(_ values: NSSet)

    @objc(removeInstances:)
    @NSManaged public func removeFromInstances(_ values: NSSet)

}

extension FocusProjectRecurrenceEntity: Identifiable {

}
