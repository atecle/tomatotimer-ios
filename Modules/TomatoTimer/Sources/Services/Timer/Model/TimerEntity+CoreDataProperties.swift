//
//  TimerEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension TimerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerEntity> {
        let request = NSFetchRequest<TimerEntity>(entityName: "TimerEntity")
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var project: FocusProjectEntity?

}

extension TimerEntity: Identifiable {

}
