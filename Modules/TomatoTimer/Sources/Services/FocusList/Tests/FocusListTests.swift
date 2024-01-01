//
//  FocusListTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer

final class FocusListTests: XCTestCase {

    func test_update_current_task() {
        let uuid = UUID()
        let tasks = [FocusListTask(id: uuid, title: "Some title", inProgress: true)]
        var sut = FocusList.standard(.init(id: uuid, tasks: tasks))

        sut.updateCurrentTask(with: "New Title")
        XCTAssert(sut.tasks[0].title == "New Title")

        sut.updateCurrentTask(with: "")
        XCTAssertTrue(sut.tasks.isEmpty)
    }

}
