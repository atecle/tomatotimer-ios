//
//  FocusProjectTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/22/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer
final class FocusProjectTests: XCTestCase {

    func test_session_complete_current_task() {
        var sut = createProject(taskCount: 4)

        sut.completeCurrentTask()

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 1)

        sut.completeCurrentTask()

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 2)

        sut.completeCurrentTask()

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 3)

        sut.completeCurrentTask()

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 0)
    }

    func test_session_toggle_task_completed() {
        var sut = createProject(taskCount: 4)

        sut.toggleCompleted(task: sut.list.tasks[0])

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 1)

        sut.toggleCompleted(task: sut.list.tasks[1])

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 2)

        sut.toggleCompleted(task: sut.list.tasks[2])

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.completedSessionCount == 3)

        sut.toggleCompleted(task: sut.list.tasks[3])

        XCTAssertTrue(sut.timer.currentSession.isWork)
        XCTAssertTrue(sut.timer.isComplete)
        XCTAssertTrue(sut.timer.completedSessionCount == 0)
    }

    func createProject(
        taskCount: Int
    ) -> FocusProject {
        return FocusProject(
            list: .session(
                .init(
                    tasks: taskCount.timesMap {
                        FocusListTask(
                            title: "Untitled Task \($0 + 1)",
                            inProgress: $0 == 0
                        )
                    }
                )
            ),
            timer: .standard(.init(config: .init(sessionCount: taskCount)))
        )
    }
}
