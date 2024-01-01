//
//  FocusListTaskEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension FocusListTaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusListTaskEntity> {
        let request = NSFetchRequest<FocusListTaskEntity>(entityName: "FocusListTaskEntity")
        request.sortDescriptors = FocusListTaskEntity.defaultSortDescriptors
        return request
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var order: Int64
    @NSManaged public var completed: Bool
    @NSManaged public var inProgress: Bool
    @NSManaged public var list: FocusListEntity?

}

extension FocusListTaskEntity: Identifiable {

}
