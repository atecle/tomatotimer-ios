//
//  WeekDay.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

@objc public enum WeekDay: Int, Identifiable, Equatable, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    public var id: Int { rawValue }

    var abbreviation: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var shortAbbreviation: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    var sortOrder: Int {
       rawValue
    }

    static var everyday: Set<WeekDay> {
        return .init(WeekDay.allCases)
    }
}
