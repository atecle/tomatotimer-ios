//
//  ActivityGoalEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension ActivityGoalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityGoalEntity> {
        let request = NSFetchRequest<ActivityGoalEntity>(entityName: "ActivityGoalEntity")
        request.sortDescriptors = ActivityGoalEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var endDate: Date?
    @NSManaged public var creationDate: Date?
    @NSManaged public var isArchived: Bool
    @NSManaged public var title: String?
    @NSManaged public var goalSeconds: Int64
    @NSManaged public var goalIntervalType: Int64
    @NSManaged public var projects: NSSet?

}

// MARK: Generated accessors for projects
extension ActivityGoalEntity {

    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: FocusProjectEntity)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: FocusProjectEntity)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)

}

extension ActivityGoalEntity: Identifiable {

}
