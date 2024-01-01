//
//  SessionListEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension SessionListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionListEntity> {
        let request = NSFetchRequest<SessionListEntity>(entityName: "SessionListEntity")
        request.sortDescriptors = SessionListEntity.defaultSortDescriptors
        return request
    }

}
