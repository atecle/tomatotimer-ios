//
//  StandardListEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension StandardListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StandardListEntity> {
        let request = NSFetchRequest<StandardListEntity>(entityName: "StandardListEntity")
        request.sortDescriptors = StandardListEntity.defaultSortDescriptors
        return request
    }

}
