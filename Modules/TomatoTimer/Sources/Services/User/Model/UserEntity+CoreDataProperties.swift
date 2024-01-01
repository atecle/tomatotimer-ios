//
//  UserEntity+CoreDataProperties.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/23/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//
//

import Foundation
import CoreData

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var purchasedPlus: Bool

}

extension UserEntity: Identifiable {

}
