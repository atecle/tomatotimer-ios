//
//  ActivityGoalClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/15/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData
import Combine
import Dependencies

// swiftlint:disable all
struct ActivityGoalClient {

    var create: (ActivityGoal) async throws -> Void
    var update: (ActivityGoal) async throws -> Void
    var delete: (ActivityGoal) async throws -> Void
    var monitorActivityGoalStatsForDateRange: ((Date, Date)) -> AnyPublisher<[ActivityGoalStatistic], Error>
    var monitor: () -> AnyPublisher<[ActivityGoal], Error>
    var monitorAll: () -> AnyPublisher<[ActivityGoal], Error>

    static func live(
        coreDataClient: CoreDataRepository<ActivityGoalEntity>
    ) -> Self {
        Self(
            create: { goal in
                try await coreDataClient.create(goal)
            },
            update: { goal in
                let request: NSFetchRequest<ActivityGoalEntity> = ActivityGoalEntity.fetchByID(id: goal.id)
                try await coreDataClient.updateOne(request) { goalEntity, context in
                    goalEntity?.update(from: goal, context: context)
                }
            },
            delete: { goal in
                let request: NSFetchRequest<ActivityGoalEntity> = ActivityGoalEntity.fetchByID(id: goal.id)
                try await coreDataClient.deleteOne(request)
            },
            monitorActivityGoalStatsForDateRange: { dateRange in
                let request = ActivityGoalEntity.fetchRequest()
                request.predicate = .init(format: "isArchived == false")
                request.sortDescriptors = ActivityGoalEntity.defaultSortDescriptors

                return coreDataClient.monitor(request)
                    .map { goals in

                        var stats: [ActivityGoalStatistic] = []
                        for goal in goals {
                            let totalElapsedTimeInDateRange: [Int] = (goal.projectStats)
                                .filter {
                                    return Calendar.current.isDateInRange(date: $0.creationDate, range: dateRange)
                                }
                                .map { Int($0.workTime + $0.breakTime) }
                            let totalElapsedTime: [Int] = (goal.projectStats)
                                .map { Int($0.workTime) }
                            stats.append(ActivityGoalStatistic(
                                dateRange: dateRange,
                                activityGoal: goal,
                                totalElapsedTimeInDateRange: TimeInterval(totalElapsedTimeInDateRange.reduce(0, +)),
                                totalElapsedTime: TimeInterval(totalElapsedTime.reduce(0, +))
                            ))
                        }

                        return stats
                    }
                    .eraseToAnyPublisher()
            },
            monitor: {
                let request = ActivityGoalEntity.fetchRequest()
                request.predicate = .init(format: "isArchived == false")
                request.sortDescriptors = ActivityGoalEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .eraseToAnyPublisher()
            },
            monitorAll: {
                let request = ActivityGoalEntity.fetchRequest()
                request.sortDescriptors = ActivityGoalEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .eraseToAnyPublisher()
            }
        )
    }
}

extension ActivityGoalClient: DependencyKey {
    static let liveValue: ActivityGoalClient = ActivityGoalClient.live(
        coreDataClient: .live(
            coreDataStack: CoreDataStack.live
        )
    )
}

extension Calendar {

    func isDateInRange(date: Date, range: (Date, Date)) -> Bool {
        return (range.0...range.1).contains(date)
    }
}

extension Date {
    var startOfWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        return Calendar.current.startOfDay(for: date.addingTimeInterval(dslTimeOffset))
    }

    var endOfWeek: Date {
        return Calendar.current.date(byAdding: .second, value: 604799, to: self.startOfWeek)!
    }
}
