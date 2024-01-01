import Foundation
import ComposableArchitecture

struct ActivitySummaryDetailReducer: ReducerProtocol {

    // MARK: - Definitions

    enum CancelID: Hashable {
        case monitor
    }

    enum Action: Equatable {
        case viewDidAppear
        case loadWeek(Week)
        case setProjects([FocusProject])

        case setTotals(WeeklyActivityTotals)
    }

    struct State: Equatable {
        var totals: WeeklyActivityTotals = .dummy
        var referenceDate: Date =  .init()
        var projectsInWeek: [FocusProject] = []
        var daysOfWeek: [Date] { referenceDate.daysOfWeek() }
        var projectsForDate: (Date) -> [FocusProject] {
            return { date in
                return projectsInWeek.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: date) }
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.focusProjectClient) var focusProjectClient

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewDidAppear:
            return .none

        case let .setTotals(totals):
            state.totals = totals
            return .none

        case let .setProjects(projects):
            state.projectsInWeek = projects
            return .none

        case let .loadWeek(week):
            state.referenceDate = week.referenceDate
            return monitor(week)
        }
    }

    func monitor(_ week: Week) -> EffectTask<Action> {
        EffectTask.cancel(id: CancelID.monitor)
            .concatenate(
                with: .merge(
                    monitorWeeklyActivityTotals(week),
                    monitorProjects(week)
                ).cancellable(id: CancelID.monitor)
            )
    }

    func monitorWeeklyActivityTotals(_ week: Week) -> EffectTask<Action> {
        focusProjectClient
            .monitorWeeklyActivityTotals(week.referenceDate)
            .catchToEffect().map { result in
                switch result {
                case let .success(totals):
                    return .setTotals(totals)
                case .failure:
                    fatalError()
                }
            }
    }

    func monitorProjects(_ week: Week) -> EffectTask<Action> {
        return focusProjectClient.monitorProjectsInWeek(week)
            .catchToEffect()
            .map { result in
                switch result {
                case let .success(projects):
                    return .setProjects(projects)
                case .failure:
                    fatalError()
                }
            }
    }
}

extension Date {
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
}
