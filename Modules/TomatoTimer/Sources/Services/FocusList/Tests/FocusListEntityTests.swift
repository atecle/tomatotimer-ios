//
//  FocusListEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
@testable import TomatoTimer

final class FocusListEntityTests: EntityTestCase {

    override func test_update() {
        // 1. Standard
        let uuid = UUID()
        let tasks = [FocusListTask(id: uuid)]
        let list = StandardList(id: uuid, tasks: tasks)
        let entity = StandardListEntity(context: context)
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
        // 1. Standard
        let uuid = UUID()
        let list1 = StandardList(id: uuid, tasks: [.init()])
        let entity1 = StandardListEntity(context: context)
        entity1.update(from: list1, context: context)
        XCTAssertEqual(
            FocusList.standard(list1),
            FocusListEntity.focusList(from: entity1)
        )

        // 2. Session
        let list2 = SessionList(id: uuid, tasks: [.init()])
        let entity2 = SessionListEntity(context: context)
        entity2.update(from: list2, context: context)
        XCTAssertEqual(
            FocusList.session(list2),
            FocusListEntity.focusList(from: entity2)
        )

        // 3. Single Task
        let list3 = SingleTaskList(id: uuid, task: .init())
        let entity3 = SingleTaskListEntity(context: context)
        entity3.update(from: list3, context: context)
        XCTAssertEqual(
            FocusList.singleTask(list3),
            FocusListEntity.focusList(from: entity3)
        )

        // 3. None
        XCTAssertEqual(
            FocusList.none,
            FocusListEntity.focusList(from: nil)
        )
    }

}
