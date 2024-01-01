//
//  Calendar+Helper.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

extension Calendar {
    func isDateBeforeToday(_ date: Date) -> Bool {
        return startOfDay(for: .now) <= date
    }
}

extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return startOfDay(for: .now) < startOfDay(for: date)
    }
}
