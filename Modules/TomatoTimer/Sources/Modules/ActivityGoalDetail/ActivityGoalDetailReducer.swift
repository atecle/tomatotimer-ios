import Foundation
import ComposableArchitecture

// swiftlint:disable all
struct ActivityGoalDetailReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setGoalWithProject(ActivityGoalWithProjects)
    }

    struct State: Equatable {
        var goal: ActivityGoal
        var activityGoalWithProject: ActivityGoalWithProjects?

        var timeSpentForDay: (Date) -> Double {
            return { date in
//                guard let goal = activityGoalWithProject else { return 0 }
//                let projects = goal.projects.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: date)}
//                return Double(projects.map(\.elapsed).reduce(0, +))
                return 0
            }
        }

        var timeSpentForWeek: (Date) -> Double {
            return { date in
//                guard let goal = activityGoalWithProject else { return 0 }
//                let projects = goal.projects.filter { Calendar.current.isDateInRange(date: $0.creationDate, range: (date.startOfWeek, date.endOfWeek)) }
//                return Double(projects.map(\.elapsed).reduce(0, +))
                return 0
            }
        }

        var projectsForToday: (Date) -> [FocusProject] {
            return { date in
                guard let goal = activityGoalWithProject else { return [] }
                let projects = goal.projects.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: date)}
                return projects
            }
        }
    }

    @Dependency(\.activityGoalClient) var activityGoalClient

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewDidAppear:
            return .none

        case let .setGoalWithProject(activityGoalWithProject):
            state.activityGoalWithProject = activityGoalWithProject
            return .none
        }
    }
}
