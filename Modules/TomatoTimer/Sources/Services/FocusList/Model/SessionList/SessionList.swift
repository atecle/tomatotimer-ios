//
//  SessionList.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

struct SessionList: Equatable {

    let id: UUID
    var tasks: [FocusListTask]

    init(
        id: UUID = .init(),
        tasks: [FocusListTask] = []
    ) {
        self.id = id
        self.tasks = tasks
    }

    mutating func updateForCompletedSessionCount(_ count: Int) {
        for index in tasks.indices {
            if index < count {
                tasks[index].completed = true
                tasks[index].inProgress = false
            } else if index == count {
                tasks[index].completed = false
                tasks[index].inProgress = true
            } else {
                tasks[index].completed = false
                tasks[index].inProgress = false
            }
        }
    }
}
