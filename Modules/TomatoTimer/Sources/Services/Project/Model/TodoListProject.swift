//
//  Project.swift
//  TomatoTimer
//
//  Created by adam on 2/8/20.
//  Copyright © 2020 Adam Tecle. All rights reserved.
//

import Foundation
import SwiftUI

struct TodoListProject: Equatable, Identifiable {

    var id: UUID
    var title: String
    var tasks: [TodoListTask]
    var isActive: Bool
    var showCompletedTasks: Bool
    var lastOpenedDate: Date

    static var `default`: TodoListProject {
        return TodoListProject(title: "Untitled Project", isActive: true, tasks: [])
    }

    init(
        id: UUID = UUID(),
        title: String = "Untitled project",
        isActive: Bool = false,
        tasks: [TodoListTask] = [],
        showCompletedTasks: Bool = true,
        lastOpenedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isActive = isActive
        self.tasks = tasks
        self.showCompletedTasks = showCompletedTasks
        self.lastOpenedDate = lastOpenedDate
    }
}

extension TodoListProject {
    var currentTask: TodoListTask? {
        return tasks.filter { $0.inProgress == true }.first
    }

    var currentTaskTitle: String {
        return tasks.filter { $0.inProgress == true }.first?.title ?? ""
    }

    var isComplete: Bool { tasks.allSatisfy { $0.completed } }

    mutating func completeCurrentTask() {
        guard
            var task = currentTask,
            let index = tasks.firstIndex(of: task) else { return }

        task.inProgress = false
        task.completed = true
        tasks[index] = task
        guard
            var nextTask = tasks.next(startingAt: task, where: { $0.completed == false && $0.inProgress == false }),
            let nextIndex = tasks.firstIndex(where: { $0.id == nextTask.id }) else { return }
        nextTask.inProgress = true
        tasks[nextIndex] = nextTask
    }
}
