//
//  SessionList+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension SessionListEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> SessionList? {
        return SessionList(entity: self)
    }

    func update(from nonManagedObject: SessionList, context: NSManagedObjectContext) {
        self.id = nonManagedObject.id
        willChangeValue(for: \.project)
        let currentTasks = NSMutableSet(set: tasks ?? .init())
        var updatedTasks: NSMutableSet = .init()
        for (index, task) in nonManagedObject.tasks.enumerated() {
            let entity = FocusListTaskEntity(context: context)
            entity.update(from: task, context: context)
            entity.order = Int64(index)
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
        didChangeValue(for: \.project)
    }
}

extension SessionList {

    init?(entity: SessionListEntity) {
        guard let id = entity.id else {
            return nil
        }

        self.init(
            id: id,
            tasks: (entity.tasks ?? .init()).compactMap { $0 as? FocusListTaskEntity }.compactMap(FocusListTask.init(entity:)).sorted(by: \.order)
        )
    }
}
