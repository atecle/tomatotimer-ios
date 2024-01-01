//
//  UserEntity+ManagedObject.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/18/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension UserEntity: ManagedObject {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        []
    }

    func toNonManagedObject() -> User? {
        return User(entity: self)
    }

    func update(from nonManagedObject: User, context: NSManagedObjectContext) {
        willChangeValue(for: \.purchasedPlus)
        self.purchasedPlus = nonManagedObject.didPurchasePlus
        didChangeValue(for: \.purchasedPlus)
    }
}

extension User {

    init?(entity: UserEntity) {
        self.init(didPurchasePlus: entity.purchasedPlus)
    }
}
