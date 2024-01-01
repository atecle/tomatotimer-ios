//
//  ToDoListProjectEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/27/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension ToDoListProjectEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListProjectEntity> {
        let request = NSFetchRequest<ToDoListProjectEntity>(entityName: "ToDoListProjectEntity")
        request.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var showCompletedTasks: Bool
    @NSManaged public var lastOpenedDate: Date?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension ToDoListProjectEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: ToDoListTaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: ToDoListTaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension ToDoListProjectEntity: Identifiable {

}
