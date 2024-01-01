//
//  NSManagedObjectContext+PerformChanges.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/27/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func performChanges(changes: @escaping () throws -> Void) async throws {
        try await perform {
            try changes()
        }
    }
}

extension NSManagedObjectContext {

    func insertObject<A: ManagedObject>() -> A where A: ManagedObject {
        guard let obj = NSEntityDescription.insertNewObject(
                forEntityName: A.entityName,
                into: self
        ) as? A else {
            fatalError("Wrong object type")
        }

        return obj
    }
}
