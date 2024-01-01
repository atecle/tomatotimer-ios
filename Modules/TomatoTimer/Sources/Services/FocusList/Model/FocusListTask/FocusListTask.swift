//
//  FocusListTask.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import SwiftUI

struct FocusListTask: Equatable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var order: Int
    var completed: Bool
    var inProgress: Bool

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        completed: Bool = false,
        inProgress: Bool = false,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.completed = completed
        self.inProgress = inProgress
        self.order = order
    }
}

extension FocusListTask {
    static var previews: [FocusListTask] {
        [
            .init(id: UUID(), title: "Untitled Task 1", completed: false, inProgress: true),
            .init(id: UUID(), title: "Untitled Task 2", completed: false, inProgress: false),
            .init(id: UUID(), title: "Untitled Task 3", completed: false, inProgress: false),
            .init(id: UUID(), title: "Untitled Task 4", completed: false, inProgress: false)
        ]
    }
}
