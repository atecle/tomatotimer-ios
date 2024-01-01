//
//  FocusListEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension FocusListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusListEntity> {
        let request = NSFetchRequest<FocusListEntity>(entityName: "FocusListEntity")
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var project: FocusProjectEntity?

}

// MARK: Generated accessors for tasks
extension FocusListEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: FocusListTaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: FocusListTaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension FocusListEntity: Identifiable {

}
