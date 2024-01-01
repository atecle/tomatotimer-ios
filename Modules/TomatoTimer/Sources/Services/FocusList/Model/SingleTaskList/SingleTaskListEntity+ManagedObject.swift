//
//  SingleTaskEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension SingleTaskListEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> SingleTaskList? {
        return SingleTaskList(entity: self)
    }

    func update(from nonManagedObject: SingleTaskList, context: NSManagedObjectContext) {
        self.id = nonManagedObject.id

        let currentTasks = NSMutableSet(set: tasks ?? .init())
        var updatedTasks: NSMutableSet = .init()
        if let task = nonManagedObject.task {
            let entity = FocusListTaskEntity(context: context)
            entity.update(from: task, context: context)
            updatedTasks = NSMutableSet(set: updatedTasks.adding(entity))
        }

        currentTasks.minus(updatedTasks as Set)
        let tasksToDelete = (tasks?.allObjects as? [NSManagedObject]) ?? []
        self.removeFromTasks(currentTasks as NSSet)
        for task in tasksToDelete {
            context.delete(task)
        }
        self.addToTasks(updatedTasks)
        tasks = updatedTasks as NSSet
    }
}

extension SingleTaskList {

    init?(entity: SingleTaskListEntity) {
        guard let id = entity.id else {
            return nil
        }

        self.init(
            id: id,
            task: (entity.tasks ?? .init()).compactMap { $0 as? FocusListTaskEntity }.compactMap(FocusListTask.init(entity:)).first
        )
    }
}
