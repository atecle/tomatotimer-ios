//
//  SessionListEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
@testable import TomatoTimer

final class SessionListEntityTests: EntityTestCase {

    override func test_update() {
        let uuid = UUID()
        let tasks = [FocusListTask(id: uuid)]
        let list = SessionList(id: uuid, tasks: tasks)
        let entity = SessionListEntity(context: context)
        entity.update(from: list, context: context)
        XCTAssertEqual(
            entity.id,
            list.id
        )
        XCTAssertEqual(
            entity.tasks?.count,
            list.tasks.count
        )
    }

    override func test_toNonManagedObject() {
        let uuid = UUID()
        let tasks = [FocusListTask(id: uuid)]
        let list = SessionList(id: uuid, tasks: tasks)
        let entity = SessionListEntity(context: context)
        entity.update(from: list, context: context)
        XCTAssertEqual(entity.toNonManagedObject(), list)
    }

}
