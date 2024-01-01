//
//  ProjectTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 5/10/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest

@testable import TomatoTimer

final class TodoListProjectTests: XCTestCase {

    let tasks: [TodoListTask] = [
        TodoListTask(),
        TodoListTask(),
        TodoListTask(),
        TodoListTask(),
        TodoListTask()
    ]

    func test_empty_project_should_have_no_current_tasks() {
        let sut = TodoListProject()
        XCTAssertNil(sut.currentTask)
    }

    func test_project_should_have_no_current_tasks_if_theres_one_task() {
        let sut = TodoListProject(title: "some", tasks: [tasks[0]])
        XCTAssertNil(sut.currentTask)
    }

    func test_project_should_have_no_current_tasks_after_you_mark_the_last_task_done() {
        var task = tasks[0]
        task.inProgress = true
        var completed = tasks[1]
        completed.completed = true
        var sut = TodoListProject(title: "some", tasks: [task, completed])
        XCTAssertNotNil(sut.currentTask)
        sut.completeCurrentTask()
        XCTAssertNil(sut.currentTask)
    }

    func test_first_current_task_is_moved_ahead_in_list_when_completed() {
        var someTasks = [tasks[0], tasks[1], tasks[2]]
        someTasks[0].inProgress = true
        var sut = TodoListProject(title: "some", tasks: someTasks)
        sut.completeCurrentTask()
        XCTAssertEqual(sut.currentTask?.id, someTasks[1].id)
    }

    func test_second_current_task_is_moved_ahead_in_list_when_completed() {
        var someTasks = [tasks[0], tasks[1], tasks[2]]
        someTasks[1].inProgress = true
        var sut = TodoListProject(title: "some", tasks: someTasks)
        sut.completeCurrentTask()
        XCTAssertEqual(sut.currentTask?.id, someTasks[2].id)
    }

    func test_last_current_task_is_moved_to_first_when_completed() {
        var someTasks = [tasks[0], tasks[1], tasks[2]]
        someTasks[2].inProgress = true
        var sut = TodoListProject(title: "some", tasks: someTasks)
        sut.completeCurrentTask()
        XCTAssertEqual(sut.currentTask?.id, someTasks[0].id)
    }

    func test_current_task_title_is_first_task_in_progress() {
        var tasks = tasks
        let title = "Test"
        tasks[3].title = title
        tasks[3].inProgress = true
        let sut = TodoListProject(tasks: tasks)
        XCTAssertEqual(sut.currentTaskTitle, title)
    }

    func test_is_completed_is_true_if_all_tasks_complete() {
        var tasks = tasks
        for index in tasks.indices { tasks[index].completed = true }
        var sut = TodoListProject(tasks: tasks)
        XCTAssertTrue(sut.isComplete)
        tasks[1].completed = false
        sut.tasks = tasks
        XCTAssertFalse(sut.isComplete)
    }
}
