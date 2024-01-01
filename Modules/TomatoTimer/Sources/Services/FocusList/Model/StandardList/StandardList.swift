//
//  StandardList.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

struct StandardList: Equatable {

    let id: UUID
    var tasks: [FocusListTask]

    init(
        id: UUID = .init(),
        tasks: [FocusListTask] = []
    ) {
        self.id = id
        self.tasks = tasks
    }
}
