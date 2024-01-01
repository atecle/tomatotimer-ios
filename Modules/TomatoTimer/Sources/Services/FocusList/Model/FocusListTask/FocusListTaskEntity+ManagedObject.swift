//
//  FocusListTaskEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension FocusListTaskEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> FocusListTask? {
        return FocusListTask(entity: self)
    }

    func update(from nonManagedObject: FocusListTask, context: NSManagedObjectContext) {
        willChangeValue(for: \.list)
        self.id = nonManagedObject.id
        self.title = nonManagedObject.title
        self.completed = nonManagedObject.completed
        self.inProgress = nonManagedObject.inProgress
        self.order = Int64(nonManagedObject.order)
        didChangeValue(for: \.list)
    }
}

extension FocusListTask {

    init?(entity: FocusListTaskEntity) {
        guard
            let id = entity.id,
            let title = entity.title else {
            return nil
        }
        self.id = id
        self.title = title
        self.completed = entity.completed
        self.inProgress = entity.inProgress
        self.order = Int(entity.order)
    }
}
