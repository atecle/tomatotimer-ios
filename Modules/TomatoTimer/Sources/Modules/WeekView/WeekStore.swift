//
//  WeekStore.swift
//  InfiniteWeekView
//
//  Created by Philipp Knoblauch on 13.05.23.
//

import Foundation

class WeekStore: ObservableObject {
    @Published var weeks: [Week] = []
    @Published var selectedDate: Date {
        didSet {
            calcWeeks(with: selectedDate)
        }
    }

    var currentWeek: Week { weeks[1] }

    init(with date: Date = Date()) {
        self.selectedDate = Calendar.current.startOfDay(for: date)
        calcWeeks(with: selectedDate)
    }

    private func calcWeeks(with date: Date) {
        weeks = [
            week(for: Calendar.current.date(byAdding: .day, value: -7, to: date)!, with: -1),
            week(for: date, with: 0),
            week(for: Calendar.current.date(byAdding: .day, value: 7, to: date)!, with: 1)
        ]
    }

    private func week(for date: Date, with index: Int) -> Week {
        var result: [Date] = .init()

        guard let startOfWeek = Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        ) else { return .init(index: index, dates: [], referenceDate: date) }

        (0...6).forEach { day in
            if let weekday = Calendar.current.date(byAdding: .day, value: day, to: startOfWeek) {
                result.append(weekday)
            }
        }

        return .init(index: index, dates: result, referenceDate: date)
    }

    func selectToday() {
        select(date: Date())
    }

    func select(date: Date) {
        selectedDate = Calendar.current.startOfDay(for: date)
    }

    func update(to direction: TimeDirection) {
        switch direction {
        case .future:
            selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!

        case .past:
            selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!

        case .unknown:
            selectedDate = selectedDate
        }

        calcWeeks(with: selectedDate)
    }
}

// MARK: - Helper

struct Week: Equatable {
    let index: Int
    let dates: [Date]
    var referenceDate: Date

    var displayString: String {
        return "\(DateFormatter.monthDayYear(from: referenceDate.startOfWeek)) - \(DateFormatter.monthDayYear(from: referenceDate.endOfWeek))"
    }
}

enum TimeDirection {
    case future
    case past
    case unknown
}

extension Date {
    func monthToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }

    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = format

        return formatter.string(from: self)
    }

    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    private func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 2

        return customCalendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameWeek(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .weekOfYear)
    }

    func isInSameDay(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .day)
    }

    static var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
