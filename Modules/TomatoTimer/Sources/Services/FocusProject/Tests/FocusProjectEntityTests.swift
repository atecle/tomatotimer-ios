//
//  FocusProjectEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import CustomDump
@testable import TomatoTimer

final class FocusProjectEntityTests: EntityTestCase {

//    override func test_update() {
//        let uuid = UUID()
//        let tasks = [FocusListTask(order: 1), FocusListTask(order: 0)]
//        var project = FocusProject(list: .standard(.init(id: uuid, tasks: tasks)))
//        let entity1 = FocusProjectEntity(context: context)
//        entity1.update(from: project, context: context)
//        XCTAssertEqual(
//            entity1.id,
//            project.id
//        )
//        XCTAssertEqual(
//            entity1.creationDate,
//            project.creationDate
//        )
//        XCTAssertEqual(
//            entity1.scheduledDate,
//            project.scheduledDate
//        )
//        XCTAssertEqual(
//            entity1.title,
//            project.title
//        )
//        XCTAssertEqual(
//            entity1.emoji,
//            project.emoji
//        )
//
////        // 1. Standard
////        var list = FocusListEntity.focusList(from: entity1.list)
//////        XCTAssertNoDifference(
//////            list,
//////            project.list
//////        )
////
////        // 2. Session
////
////        project.list = .session(.init(id: uuid, tasks: tasks))
////        let entity2 = FocusProjectEntity(context: context)
////        entity2.update(from: project, context: context)
////        list = FocusListEntity.focusList(from: entity2.list)
////        XCTAssertEqual(
////            list,
////            project.list
////        )
////        // 3. Single Task
////
////        project.list = .singleTask(.init(id: uuid, task: tasks[0]))
////        let entity3 = FocusProjectEntity(context: context)
////        entity3.update(from: project, context: context)
////        list = FocusListEntity.focusList(from: entity3.list)
////        XCTAssertEqual(
////            list,
////            project.list
////        )
////
////        // 4. None
////        project.list = .none
////        let entity4 = FocusProjectEntity(context: context)
////        entity4.update(from: project, context: context)
////        list = FocusListEntity.focusList(from: entity4.list)
////        XCTAssertEqual(
////            list,
////            project.list
////        )
////
////        XCTAssertEqual(
////            entity1.themeColorHexString,
////            project.themeColor.hexString()
////        )
////        let focusTimer = TimerEntity.focusTimer(from: entity1.timer!)
////        XCTAssertEqual(
////            focusTimer,
////            project.timer
////        )
////        XCTAssertEqual(
////            entity1.isActive,
////            project.isActive
////        )
//    }
//
//    override func test_toNonManagedObject() {
//        let project = FocusProject()
//        let entity = FocusProjectEntity(context: context)
//
//        entity.update(from: project, context: context)
//        XCTAssertNoDifference(entity.toNonManagedObject()?.list, project.list)
//        XCTAssertNoDifference(entity.toNonManagedObject()?.timer, project.timer)
//    }

}
