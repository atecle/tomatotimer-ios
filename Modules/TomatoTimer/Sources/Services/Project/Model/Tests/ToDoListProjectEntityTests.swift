//
//  ToDoListProjectEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/29/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import CoreData
import ComposableArchitecture
import XCTestDynamicOverlay
@testable import TomatoTimer

final class ToDoListProjectEntityTests: EntityTestCase {

    let tasks = (0...5).map { TodoListTask(order: $0) }

   override  func test_update() {
        let tasks = tasks
        let nonmanaged = TodoListProject(title: "Test", tasks: tasks)

        let entity = ToDoListProjectEntity(context: context)
        entity.update(from: nonmanaged, context: context)
        XCTAssertEqual(
            entity.id, nonmanaged.id
        )
        XCTAssertEqual(
            entity.title, nonmanaged.title
        )
        XCTAssertNoDifference(
            entity.tasks?.count ?? 0,
            tasks.count
        )
//       XCTAssertNoDifference(
//           entity.tasks,
//           NSSet(array: tasks.enumerated().map { (index: Int, task: TodoListTask) -> ToDoListTaskEntity in
//               let taskEntity = ToDoListTaskEntity(context: context)
//               taskEntity.update(from: task, context: context)
//               taskEntity.id = task.id
//               taskEntity.order = Int64(index)
//               taskEntity.project = entity
//               return taskEntity
//           })
//       )
        XCTAssertEqual(
            entity.isActive, nonmanaged.isActive
        )
        XCTAssertEqual(
            entity.showCompletedTasks, nonmanaged.showCompletedTasks
        )
        XCTAssertEqual(
            entity.lastOpenedDate, nonmanaged.lastOpenedDate
        )
    }

    override func test_toNonManagedObject() {
        let tasks = tasks
        let nonmanaged = TodoListProject(title: "Test", tasks: tasks)

        let entity = ToDoListProjectEntity(context: context)
        entity.update(from: nonmanaged, context: context)
        let result = entity.toNonManagedObject()
        XCTAssertNoDifference(result, nonmanaged)
    }

}
