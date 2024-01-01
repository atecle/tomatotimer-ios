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

extension FocusProjectEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    public class func fetchIsActiveRequest(_ isActive: Bool) -> NSFetchRequest<FocusProjectEntity> {
        let request = Self.fetchRequest()
        request.predicate = .init(format: "isActive == %@", NSNumber(value: isActive))
        return request
    }

    func toNonManagedObject() -> FocusProject? {
        return FocusProject(entity: self)
    }

    // swiftlint:disable:next function_body_length
    func update(from nonManagedObject: FocusProject, context: NSManagedObjectContext) {
        self.willChangeValue(for: \.timer)
        self.willChangeValue(for: \.list)
        id = nonManagedObject.id
        title = nonManagedObject.title
        emoji = nonManagedObject.emoji
        themeColorHexString = nonManagedObject.themeColor.hexString(false)
        creationDate = nonManagedObject.creationDate
        scheduledDate = nonManagedObject.scheduledDate
        isActive = nonManagedObject.isActive

        switch nonManagedObject.timer {
        case let .standard(timer):
            if self.timer == nil {
                self.timer = StandardTimerEntity(context: context)
                context.insert(self.timer!)
            }
            (self.timer as? StandardTimerEntity)?.update(from: timer, context: context)
        case let .stopwatch(timer):
            if self.timer == nil {
                self.timer = StopwatchTimerEntity(context: context)
                context.insert(self.timer!)
            }
            (self.timer as? StopwatchTimerEntity)?.update(from: timer, context: context)
        }
        switch nonManagedObject.list {
        case let .standard(standardList):
            if self.list == nil {
                self.list = StandardListEntity(context: context)
                context.insert(self.list!)
            }
            (self.list as? StandardListEntity)?.update(from: standardList, context: context)
        case let .session(sessionList):
            if self.list == nil {
                self.list = SessionListEntity(context: context)
                context.insert(self.list!)
            }
            (self.list as? SessionListEntity)?.update(from: sessionList, context: context)
        case let .singleTask(singleTaskList):
            if self.list == nil {
                self.list = SingleTaskListEntity(context: context)
                context.insert(self.list!)
            }
            (self.list as? SingleTaskListEntity)?.update(from: singleTaskList, context: context)
        case .none:
            break
        }

        if let recurrenceTemplate = nonManagedObject.recurrenceTemplate {
            if self.recurrenceTemplate == nil {
                let recurrenceEntity = FocusProjectRecurrenceEntity(context: context)
                context.insert(recurrenceEntity)
                recurrenceEntity.update(from: recurrenceTemplate, context: context)
                recurrenceEntity.template = self
                self.recurrenceTemplate = recurrenceEntity
            } else {
                self.recurrenceTemplate?.update(from: recurrenceTemplate, context: context)
                self.recurrenceTemplate?.template = self
            }
        }

        if let recurrence = nonManagedObject.recurrence {
            self.recurrence?.update(from: recurrence, context: context)
        }

        self.didChangeValue(for: \.timer)
        self.didChangeValue(for: \.list)
    }
}

extension NSPredicate {
    static func scheduledDatePredicate(for date: Date) -> NSPredicate {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        // following creates exact midnight 12:00:00:000 AM of day
        let startOfDay = calendar.startOfDay(for: date)
        // following creates exact midnight 12:00:00:000 AM of next day
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return NSPredicate(format: "scheduledDate >= %@ AND scheduledDate < %@", argumentArray: [startOfDay, endOfDay])
    }

    static func dateRangePredicate(dateRange: (Date, Date)) -> NSPredicate {
        return NSPredicate(format: "creationDate >= %@ AND creationDate < %@", argumentArray: [dateRange.0, dateRange.1])
    }

}

extension FocusProject {

    init?(entity: FocusProjectEntity) {
        guard
            let id = entity.id,
            let title = entity.title,
            let creationDate = entity.creationDate,
            let scheduledDate = entity.scheduledDate,
            let emoji = entity.emoji,
            let themeColorHexString = entity.themeColorHexString,
            let timerEntity = entity.timer else {
            return nil
        }

        let timer: FocusTimer = TimerEntity.focusTimer(from: timerEntity)
        let list: FocusList = FocusListEntity.focusList(from: entity.list)
        let recurrence: FocusProject.Recurrence?
        if let recurrenceEntity = entity.recurrence {
            recurrence = FocusProject.Recurrence(entity: recurrenceEntity)
        } else {
            recurrence = nil
        }

        let recurrenceTemplate: FocusProject.Recurrence?
        if let recurrenceEntity = entity.recurrenceTemplate {
            recurrenceTemplate = FocusProject.Recurrence(entity: recurrenceEntity)
        } else {
            recurrenceTemplate = nil
        }

        let activityGoals = (entity.activityGoals ?? .init()).compactMap { $0 as? ActivityGoalEntity }.compactMap(ActivityGoal.init(entity:))
        self.init(
            id: id,
            title: title,
            creationDate: creationDate,
            scheduledDate: scheduledDate,
            emoji: emoji,
            themeColor: UIColor(themeColorHexString),
            list: list,
            timer: timer,
            isActive: entity.isActive,
            recurrence: recurrence,
            recurrenceTemplate: recurrenceTemplate,
            activityGoals: activityGoals
        )
    }
}
