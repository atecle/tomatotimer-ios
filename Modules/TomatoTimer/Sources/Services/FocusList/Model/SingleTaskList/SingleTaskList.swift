//
//  SingleTaskList.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/3/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

struct SingleTaskList: Equatable {

    let id: UUID
    var task: FocusListTask?

    init(
        id: UUID = .init(),
        task: FocusListTask? = nil
    ) {
        self.id = id
        self.task = task
    }
}
