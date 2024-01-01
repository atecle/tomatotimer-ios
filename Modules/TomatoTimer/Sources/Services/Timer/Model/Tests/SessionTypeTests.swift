//
//  SessionTypeTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/29/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
@testable import TomatoTimer

final class SessionTypeTests: XCTestCase {

    func test_isBreak() {
        XCTAssertTrue(SessionType.shortBreak.isBreak)
        XCTAssertTrue(SessionType.longBreak.isBreak)
        XCTAssertFalse(SessionType.work.isBreak)
    }

}
