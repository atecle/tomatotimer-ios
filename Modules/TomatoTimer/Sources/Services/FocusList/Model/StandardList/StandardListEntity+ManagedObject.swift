//
//  StandardListEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension StandardListEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> StandardList? {
        return StandardList(entity: self)
    }

    func update(from nonManagedObject: StandardList, context: NSManagedObjectContext) {
        self.project?.willChangeValue(for: \.list)
        self.id = nonManagedObject.id
        let currentTasks = NSMutableSet(set: tasks ?? .init())
        var updatedTasks: NSMutableSet = .init()
        for (index, task) in nonManagedObject.tasks.enumerated() {
            var task = task
            task.order = index
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
        self.project?.didChangeValue(for: \.list)
    }
}

extension StandardList {

    init?(entity: StandardListEntity) {
        guard let id = entity.id else {
            return nil
        }

        self.init(
            id: id,
            tasks: (entity.tasks ?? .init())
                .compactMap { $0 as? FocusListTaskEntity }
                .compactMap(FocusListTask.init(entity:))
                .sorted(by: \.order)
        )
    }
}
