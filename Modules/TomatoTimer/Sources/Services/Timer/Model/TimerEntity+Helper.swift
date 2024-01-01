//
//  TimerEntity+Helper.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

extension TimerEntity {

    static func focusTimer(from entity: TimerEntity) -> FocusTimer {
        let timer: FocusTimer
        if
            entity.isKind(of: StandardTimerEntity.self),
            let standardTimerEntity = entity as? StandardTimerEntity,
            let standardTimer = StandardTimer(entity: standardTimerEntity) {
            timer = .standard(standardTimer)
        } else if entity.isKind(of: StopwatchTimerEntity.self),
           let stopwatchTimerEntity = entity as? StopwatchTimerEntity,
           let stopwatchTimer = StopwatchTimer(entity: stopwatchTimerEntity) {
            timer = .stopwatch(stopwatchTimer)
        } else {
            fatalError()
        }

        return timer
    }

    func update(from timer: FocusTimer, context: NSManagedObjectContext) {
        switch timer {
        case let .standard(timer):
            if self.isKind(of: StandardTimerEntity.self) {
                (self as? StandardTimerEntity)?.update(from: timer, context: context)
            }
        case let .stopwatch(timer):
            if self.isKind(of: StopwatchTimerEntity.self) {
                (self as? StopwatchTimerEntity)?.update(from: timer, context: context)
            }
        }
    }
}
