//
//  ToDoListProjectEntity+Managed.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/27/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension ToDoListProjectEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> TodoListProject? {
        return TodoListProject(entity: self)
    }

    func update(from nonManagedObject: TodoListProject, context: NSManagedObjectContext) {
        id = nonManagedObject.id
        title = nonManagedObject.title
        isActive = nonManagedObject.isActive
        showCompletedTasks = nonManagedObject.showCompletedTasks
        lastOpenedDate = nonManagedObject.lastOpenedDate

        let currentTasks = NSMutableSet(set: tasks ?? .init())
        var updatedTasks: NSMutableSet = .init()
        for (index, task) in nonManagedObject.tasks.enumerated() {
            let entity = ToDoListTaskEntity(context: context)
            entity.id = task.id
            entity.title = task.title
            entity.creationDate = task.creationDate
            entity.inProgress = task.inProgress
            entity.completed = task.completed
            entity.order = Int64(index)
            updatedTasks = NSMutableSet(set: updatedTasks.adding(entity))
        }

        currentTasks.minus(updatedTasks as Set)
        self.removeFromTasks(currentTasks as NSSet)
        self.addToTasks(updatedTasks)
        tasks = updatedTasks as NSSet
    }
}

extension TodoListProject {

    init?(entity: ToDoListProjectEntity) {
        guard
            let id = entity.id,
            let title = entity.title,
            let lastOpenedDate = entity.lastOpenedDate else {
            return nil
        }

        self.init(
            id: id,
            title: title,
            isActive: entity.isActive,
            tasks: (entity.tasks ?? .init()).compactMap { $0 as? ToDoListTaskEntity }.compactMap(TodoListTask.init(entity:)).sorted(by: \.order),
            showCompletedTasks: entity.showCompletedTasks,
            lastOpenedDate: lastOpenedDate
        )
    }
}
