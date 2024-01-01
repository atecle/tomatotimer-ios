//
//  ActivityGoal+ManagedObject.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension ActivityGoalEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> ActivityGoal? {
        return ActivityGoal(entity: self)
    }

    func update(from nonManagedObject: ActivityGoal, context: NSManagedObjectContext) {
        self.id = nonManagedObject.id
        self.creationDate = nonManagedObject.creationDate
        self.endDate = nonManagedObject.endDate
        self.isArchived = nonManagedObject.isArchived
        self.title = nonManagedObject.title
        self.goalIntervalType = Int64(nonManagedObject.goalIntervalType.rawValue)
        self.goalSeconds = Int64(nonManagedObject.goalSeconds)
    }
}

extension ActivityGoal {

    init?(entity: ActivityGoalEntity) {
        guard
            let id = entity.id,
            let creationDate = entity.creationDate,
            let goalIntervalType = GoalIntervalType(rawValue: Int(entity.goalIntervalType)),
            let title = entity.title else {
            return nil
        }

        let projectStats = (entity.projects ?? .init())
            .compactMap { ($0 as? FocusProjectEntity) }
            .compactMap { (entity: FocusProjectEntity) -> ProjectStats? in
                guard let id = entity.id, let creationDate = entity.creationDate else { return nil }

                let workTime: Int64
                let breakTime: Int64
                if let timer = (entity.timer as? StandardTimerEntity) {
                    workTime = timer.totalWorkTime
                    breakTime = timer.totalBreakTime
                } else if let timer = (entity.timer as? StopwatchTimerEntity) {
                    workTime = timer.workTime
                    breakTime = timer.breakTime
                } else {
                    return nil
                }

                return ProjectStats(
                    projectID: id,
                    creationDate: creationDate,
                    workTime: TimeInterval(workTime),
                    breakTime: TimeInterval(breakTime)
                )
            }

        self.init(
            id: id,
            creationDate: creationDate,
            endDate: entity.endDate,
            isArchived: entity.isArchived,
            title: title,
            goalIntervalType: goalIntervalType,
            goalSeconds: TimeInterval(entity.goalSeconds),
            projectStats: projectStats
        )
    }
}
