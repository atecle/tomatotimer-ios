//
//  ActivityGoal.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

enum GoalIntervalType: Int, Equatable, CaseIterable {
    case daily
    case weekly

    var description: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        }
    }
}

struct ProjectStats: Equatable {
    let projectID: UUID
    let creationDate: Date
    let workTime: TimeInterval
    let breakTime: TimeInterval
}

struct ActivityGoal: Equatable {
    let id: UUID
    let creationDate: Date
    let endDate: Date?
    var isArchived: Bool
    var title: String
    var goalIntervalType: GoalIntervalType
    var goalSeconds: TimeInterval
    var projectStats: [ProjectStats]

    init(
        id: UUID = UUID(),
        creationDate: Date = Date(),
        endDate: Date? = nil,
        isArchived: Bool = false,
        title: String = "",
        goalIntervalType: GoalIntervalType = .daily,
        goalSeconds: TimeInterval = 60 * 20,
        projectStats: [ProjectStats] = []
    ) {
        self.id = id
        self.creationDate = creationDate
        self.endDate = endDate
        self.isArchived = isArchived
        self.title = title
        self.goalIntervalType = goalIntervalType
        self.goalSeconds = goalSeconds
        self.projectStats = projectStats
    }
}

struct ActivityTotals: Equatable {
    var numberOfProjects: Int = 0
    var workSecondsElapsed: Int = 0
    var breakSecondsElapsed: Int = 0
}

struct WeeklyActivityTotals: Equatable {
    var totals: [WeekDay: Int] = [:]
    var lastWeekTotals: Int = 0

    var thisWeekTotals: Int {
        return Array(totals.values).reduce(0, +)
    }

    var deltaFromLastWeek: Double {
        let delta = thisWeekTotals - lastWeekTotals
        let percentage = (Double(delta) / Double(lastWeekTotals))
        return percentage
    }
}

struct ActivityGoalWithProjects: Equatable {
    var activityGoal: ActivityGoal
    var projects: [FocusProject]
}

extension ActivityGoal: Identifiable {}

struct ActivityGoalStatistic: Equatable, Identifiable {
    var id: UUID { activityGoal.id }
    var dateRange: (Date, Date)
    var activityGoal: ActivityGoal
    var totalElapsedTimeInDateRange: TimeInterval
    var totalElapsedTime: TimeInterval

    static func == (lhs: ActivityGoalStatistic, rhs: ActivityGoalStatistic) -> Bool {
            lhs.id == rhs.id
            && ((lhs.dateRange.0 == rhs.dateRange.0) && (lhs.dateRange.1 == rhs.dateRange.1))
            && lhs.totalElapsedTimeInDateRange == rhs.totalElapsedTimeInDateRange
    }
}
