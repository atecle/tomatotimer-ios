//
//  StopwatchEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer

final class StopwatchEntityTests: EntityTestCase {

    override func test_update() {
        let id = UUID()
        var timer = StopwatchTimer(id: id)
        timer.incrementTime()
        timer.incrementTime()
        let entity = StopwatchTimerEntity(context: context)

        entity.update(from: timer, context: context)

        XCTAssertEqual(
            entity.id,
            timer.id
        )
        XCTAssertEqual(
            entity.currentSession,
            Int64(timer.currentSession.rawValue)
        )
        XCTAssertEqual(
            entity.isRunning,
            timer.isRunning
        )
        XCTAssertEqual(
            entity.workTime,
            Int64(timer.workTime)
        )
        XCTAssertEqual(
            entity.breakTime,
            Int64(timer.breakTime)
        )
    }

    override func test_toNonManagedObject() {
        var timer = StopwatchTimer()
        let entity = StopwatchTimerEntity(context: context)

        entity.update(from: timer, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), timer)

        timer.toggleSession()
        timer.incrementTime()
        entity.update(from: timer, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), timer)
    }

}
