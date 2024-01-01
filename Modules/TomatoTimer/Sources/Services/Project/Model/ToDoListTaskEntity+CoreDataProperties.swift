//
//  ToDoListTaskEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/27/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension ToDoListTaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListTaskEntity> {
        let request = NSFetchRequest<ToDoListTaskEntity>(entityName: "ToDoListTaskEntity")
        request.sortDescriptors = ToDoListTaskEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var order: Int64
    @NSManaged public var inProgress: Bool
    @NSManaged public var completed: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var project: ToDoListProjectEntity?

}

extension ToDoListTaskEntity: Identifiable {

}
