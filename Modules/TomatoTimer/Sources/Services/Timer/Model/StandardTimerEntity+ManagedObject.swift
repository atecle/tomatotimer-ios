//
//  StandardTimerEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension StandardTimerEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> StandardTimer? {
        return StandardTimer(entity: self)
    }

    func update(from nonManagedObject: StandardTimer, context: NSManagedObjectContext) {
        self.project?.willChangeValue(for: \.timer)
        id = nonManagedObject.id
        isRunning = nonManagedObject.isRunning
        timeLeftInSession = Int64(nonManagedObject.timeLeftInSession)
        currentSession = Int64(nonManagedObject.currentSession.rawValue)
        completedSessionCount = Int64(nonManagedObject.completedSessionCount)
        isComplete = nonManagedObject.isComplete
        wasStarted = nonManagedObject.wasStarted
        workSessionLength = Int64(nonManagedObject.config.workSessionLength)
        shortBreakLength = Int64(nonManagedObject.config.shortBreakLength)
        longBreakLength = Int64(nonManagedObject.config.longBreakLength)
        sessionCount = Int64(nonManagedObject.config.sessionCount)
        autostartWorkSession = nonManagedObject.config.autostartWorkSession
        autostartBreakSession = nonManagedObject.config.autostartBreakSession
        workSound = Int64(nonManagedObject.config.workSound.rawValue)
        breakSound = Int64(nonManagedObject.config.breakSound.rawValue)
        totalWorkTime = Int64(nonManagedObject.totalWorkTime)
        totalBreakTime = Int64(nonManagedObject.totalBreakTime)
        self.project?.didChangeValue(for: \.timer)
    }
}

extension StandardTimer {

    init?(entity: StandardTimerEntity) {
        guard
            let id = entity.id,
            let currentSession = SessionType(rawValue: Int(entity.currentSession)) else {
            return nil
        }
        self.id = id
        self.config = .init(
            workSessionLength: Int(entity.workSessionLength),
            shortBreakLength: Int(entity.shortBreakLength),
            longBreakLength: Int(entity.longBreakLength),
            sessionCount: Int(entity.sessionCount),
            autostartWorkSession: entity.autostartWorkSession,
            autostartBreakSession: entity.autostartBreakSession,
            workSound: NotificationSound(rawValue: Int(entity.workSound)) ?? .bell,
            breakSound: NotificationSound(rawValue: Int(entity.breakSound)) ?? .bell
        )
        self.isRunning = entity.isRunning
        self.isComplete = entity.isComplete
        self.wasStarted = entity.wasStarted
        self.currentSession = currentSession
        self.completedSessionCount = Int(entity.completedSessionCount)
        self.timeLeftInSession = Int(entity.timeLeftInSession)
        self.totalWorkTime = Int(entity.totalWorkTime)
        self.totalBreakTime = Int(entity.totalBreakTime)
    }
}
