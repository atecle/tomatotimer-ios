//
//  StandardTimerEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer

final class StandardTimerEntityTests: EntityTestCase {

    override func test_update() {
        let id = UUID()
        let config = StandardTimerConfiguration(
            workSessionLength: 60,
            shortBreakLength: 60,
            longBreakLength: 60,
            sessionCount: 4,
            autostartWorkSession: true,
            autostartBreakSession: true,
            workSound: .bell,
            breakSound: .toodleLoo
        )
        let timer = StandardTimer(id: id, config: config)
        let entity = StandardTimerEntity(context: context)
        entity.update(from: timer, context: context)
        XCTAssertEqual(
            entity.id,
            timer.id
        )
        XCTAssertEqual(
            entity.isRunning,
            timer.isRunning
        )
        XCTAssertEqual(
            entity.timeLeftInSession,
            Int64(timer.timeLeftInSession)
        )
        XCTAssertEqual(
            entity.currentSession,
            Int64(timer.currentSession.rawValue)
        )
        XCTAssertEqual(
            entity.completedSessionCount,
            Int64(timer.completedSessionCount)
        )
        XCTAssertEqual(
            entity.isComplete,
            timer.isComplete
        )
        XCTAssertEqual(
            StandardTimerConfiguration(
                workSessionLength: Int(entity.workSessionLength),
                shortBreakLength: Int(entity.shortBreakLength),
                longBreakLength: Int(entity.longBreakLength),
                sessionCount: Int(entity.sessionCount),
                autostartWorkSession: entity.autostartWorkSession,
                autostartBreakSession: entity.autostartBreakSession,
                workSound: NotificationSound(rawValue: Int(entity.workSound))!,
                breakSound: NotificationSound(rawValue: Int(entity.breakSound))!
            ),
            timer.config
        )
    }

    override func test_toNonManagedObject() {
        var timer = StandardTimer()
        let entity = StandardTimerEntity(context: context)

        entity.update(from: timer, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), timer)

        timer.complete()
        timer.decrementTime()
        entity.update(from: timer, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), timer)
    }

}
