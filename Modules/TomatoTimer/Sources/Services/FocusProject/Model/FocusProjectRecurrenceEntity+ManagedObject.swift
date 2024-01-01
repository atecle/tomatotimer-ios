//
//  FocusProjectEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData
import UIColorHexSwift
import UIKit

extension FocusProjectRecurrenceEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> FocusProject.Recurrence? {
        return FocusProject.Recurrence(entity: self)
    }

    func update(from nonManagedObject: FocusProject.Recurrence, context: NSManagedObjectContext) {
        id = nonManagedObject.id
        reminderDate = nonManagedObject.reminderDate
        repeatingDays = NSMutableSet(
            array: Array(
                nonManagedObject.repeatingDays.map(\.rawValue).map(NSNumber.init(integerLiteral:))
            )
        )
        endDate = nonManagedObject.endDate
    }
}

extension FocusProject.Recurrence {

    init?(entity: FocusProjectRecurrenceEntity) {
        guard let id = entity.id, let templateProjectID = entity.template?.id else { return nil }
        var repeatingDays: Set<WeekDay> = .init()
        for case let day as NSNumber in (entity.repeatingDays ?? .init()) {
            if let weekday = WeekDay(rawValue: day.intValue) {
                repeatingDays.insert(weekday)
            }
        }
        self.init(
            id: id,
            templateProjectID: templateProjectID,
            repeatingDays: repeatingDays,
            endDate: entity.endDate,
            reminderDate: entity.reminderDate
        )
    }
}
