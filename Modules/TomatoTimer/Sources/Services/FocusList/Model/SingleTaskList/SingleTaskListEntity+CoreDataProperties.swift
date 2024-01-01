//
//  SingleTaskListEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension SingleTaskListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SingleTaskListEntity> {
        let request = NSFetchRequest<SingleTaskListEntity>(entityName: "SingleTaskListEntity")
        request.sortDescriptors = SingleTaskListEntity.defaultSortDescriptors
        return request
    }

}
