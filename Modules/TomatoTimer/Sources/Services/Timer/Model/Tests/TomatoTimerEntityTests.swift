//
//  TomatoTimerEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/29/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
@testable import TomatoTimer

final class TomatoTimerEntityTests: EntityTestCase {

    override func test_update() {
        let timer = TomatoTimer()
        let entity = TomatoTimerEntity(context: context)

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
            entity.timeLeftInCurrentSession,
            Int64(timer.secondsLeftInCurrentSession)
        )
        XCTAssertEqual(
            entity.workSessionLength,
            Int64(timer.timerSessions.workSessionLength)
        )
        XCTAssertEqual(
            entity.shortBreakLength,
            Int64(timer.timerSessions.shortBreakLength)
        )
        XCTAssertEqual(
            entity.longBreakLength,
            Int64(timer.timerSessions.longBreakLength)
        )
        XCTAssertEqual(
            entity.numberOfTimerSessions,
            Int64(timer.timerSessions.numberOfTimerSessions)
        )
        XCTAssertEqual(
            entity.completedSessionsCount,
            Int64(timer.completedSessionsCount)
        )
        XCTAssertEqual(
            entity.shouldAutostartNextWorkSession,
            timer.shouldAutostartNextWorkSession
        )
        XCTAssertEqual(
            entity.shouldAutostartNextBreakSession,
            timer.shouldAutostartNextBreakSession
        )
        XCTAssertEqual(
            entity.currentSession,
            Int64(timer.currentSession.rawValue)
        )
        XCTAssertEqual(
            entity.creationDate,
            timer.creationDate
        )
    }

    override func test_toNonManagedObject() {
        let timer = TomatoTimer()
        let entity = TomatoTimerEntity(context: context)

        entity.update(from: timer, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), timer)
    }
}
