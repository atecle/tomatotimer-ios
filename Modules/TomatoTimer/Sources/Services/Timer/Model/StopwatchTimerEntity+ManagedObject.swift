//
//  StopwatchTimerEntity+Managed+NonManaged.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension StopwatchTimerEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> StopwatchTimer? {
        return StopwatchTimer(entity: self)
    }

    func update(from nonManagedObject: StopwatchTimer, context: NSManagedObjectContext) {
        self.project?.willChangeValue(for: \.timer)
        id = nonManagedObject.id
        isRunning = nonManagedObject.isRunning
        isComplete = nonManagedObject.isComplete
        currentSession = Int64(nonManagedObject.currentSession.rawValue)
        workTime = Int64(nonManagedObject.workTime)
        breakTime = Int64(nonManagedObject.breakTime)
        elapsedWorkTime = Int64(nonManagedObject.elapsedWorkTime)
        elapsedBreakTime = Int64(nonManagedObject.elapsedBreakTime)
        isComplete = nonManagedObject.isComplete
        hasBegun = nonManagedObject.hasBegun
        self.project?.didChangeValue(for: \.timer)
    }
}

extension StopwatchTimer {

    init?(entity: StopwatchTimerEntity) {
        guard
            let id = entity.id,
            let session = StopwatchTimerSessionType(rawValue: Int(entity.currentSession)) else {
            return nil
        }
        self.init(
            id: id,
            currentSession: session,
            isRunning: entity.isRunning,
            hasBegun: entity.hasBegun,
            isComplete: entity.isComplete,
            workTime: Int(entity.workTime),
            breakTime: Int(entity.breakTime),
            elapsedWorkTime: Int(entity.elapsedWorkTime),
            elapsedBreakTime: Int(entity.elapsedBreakTime)
        )
    }
}
