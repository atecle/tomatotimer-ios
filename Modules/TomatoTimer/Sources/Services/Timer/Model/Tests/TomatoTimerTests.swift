//
//  TomatoTimerTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 5/10/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer

final class TomatoTimerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    // swiftlint:disable function_body_length
    func test_timer_decrements_time_correctly() {
        var sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 10,
                totalSecondsInShortBreakSession: 15,
                totalSecondsInLongBreakSession: 25,
                numberOfTimerSessions: 4,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        /// Confirm initial state
        XCTAssertEqual(sut.completedSessionsCount, 0)
        XCTAssertEqual(sut.currentSession, .work)
        XCTAssertEqual(sut.hasBegun, false)
        XCTAssertEqual(sut.isRunning, false)

        /// First Session
        var count = 10
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<10 {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 0)
        XCTAssertEqual(sut.currentSession, .shortBreak)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 15)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 15)

        count = 15
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        /// Second Session

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 1)
        XCTAssertEqual(sut.currentSession, .work)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 10)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 10)

        count = 10
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 1)
        XCTAssertEqual(sut.currentSession, .shortBreak)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 15)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 15)

        count = 15
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        /// Third Session

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 2)
        XCTAssertEqual(sut.currentSession, .work)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 10)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 10)

        count = 10
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 2)
        XCTAssertEqual(sut.currentSession, .shortBreak)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 15)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 15)

        count = 15
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        /// Fourth Session

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 3)
        XCTAssertEqual(sut.currentSession, .work)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 10)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 10)

        count = 10
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 3)
        XCTAssertEqual(sut.currentSession, .longBreak)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 25)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 25)

        count = 25
        XCTAssertEqual(sut.totalSecondsInCurrentSession, count)
        for _ in 0..<count {
            count -= 1
            sut.decrementTime()
            XCTAssertEqual(sut.secondsLeftInCurrentSession, count)
        }

        sut.decrementTime()
        XCTAssertEqual(sut.completedSessionsCount, 0)
        XCTAssertEqual(sut.currentSession, .work)
        XCTAssertEqual(sut.totalSecondsInCurrentSession, 10)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 10)
        XCTAssertEqual(sut.isRunning, false)
    }

    func test_timer_should_not_continue_if_autostart_flag_is_off() {

    }

    func test_totalSecondsInTimerLeft() {
        var sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 1,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        XCTAssertEqual(sut.timerSessions.totalSecondsInTimerLeft, 120)

        sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 1,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )
        sut.decrementTime()

        XCTAssertEqual(sut.timerSessions.totalSecondsInTimerLeft, 119)

        sut.decrementTime()
        sut.decrementTime()
        XCTAssertEqual(sut.timerSessions.totalSecondsInTimerLeft, 117)
    }

    func test_elapsed_time() {
        var sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 1,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        sut.isRunning = true
        sut.setTimeElapsed(10)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 50)

        sut.setTimeElapsed(60)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 50)
        XCTAssertEqual(sut.currentSession, .longBreak)

        sut.setTimeElapsed(120)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 60)
        XCTAssertEqual(sut.currentSession, .work)

        sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 1,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        sut.isRunning = true
        sut.setTimeElapsed(400)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 60)
        XCTAssertEqual(sut.currentSession, .work)

        sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 4,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        sut.isRunning = true
        sut.setTimeElapsed(80)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 40)
        XCTAssertEqual(sut.currentSession, .shortBreak)

        sut = TomatoTimer(
            config: TomatoTimerConfiguration(
                totalSecondsInWorkSession: 60,
                totalSecondsInShortBreakSession: 60,
                totalSecondsInLongBreakSession: 60,
                numberOfTimerSessions: 4,
                shouldAutostartNextWorkSession: true,
                shouldAutostartNextBreakSession: true
            )
        )

        sut.isRunning = true
        sut.setTimeElapsed(320)
        XCTAssertEqual(sut.secondsLeftInCurrentSession, 40)
        XCTAssertEqual(sut.currentSession, .shortBreak)
        XCTAssertEqual(sut.completedSessionsCount, 2)
    }

}
