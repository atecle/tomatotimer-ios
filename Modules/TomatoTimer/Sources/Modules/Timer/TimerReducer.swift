import Foundation
import ComposableArchitecture
import UIKit

struct TimerReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        // Child
        case standard(StandardTimerReducer.Action)
        case stopwatch(StopwatchTimerReducer.Action)

        case handleBackgroundMode
        case suspendBackgroundMode
    }

    enum State: Equatable {
        case standard(StandardTimerReducer.State)
        case stopwatch(StopwatchTimerReducer.State)

        init(
            project: FocusProject = .init()
        ) {
            switch project.timer {
            case let .standard(timer):
                self = .standard(.init(timer: timer, project: project))
            case let .stopwatch(timer):
                self = .stopwatch(.init(timer: timer, project: project))
            }
        }
    }

    // MARK: - Properties

    var body: some ReducerProtocolOf<Self> {
        Scope(state: /State.standard, action: /Action.standard) {
            StandardTimerReducer()
        }
        Scope(state: /State.stopwatch, action: /Action.stopwatch) {
            StopwatchTimerReducer()
        }
        Reduce { state, action in
            switch action {
            case .handleBackgroundMode:
                switch state {
                case .standard:
                    return .task {
                        .standard(.handleBackgroundMode)
                    }
                case .stopwatch:
                    return .task {
                        .stopwatch(.handleBackgroundMode)
                    }
                }
            case .suspendBackgroundMode:
                switch state {
                case .standard:
                    return .task {
                        .standard(.suspendBackgroundMode)
                    }
                case .stopwatch:
                    return .task {
                        .stopwatch(.suspendBackgroundMode)
                    }
                }
            case .standard, .stopwatch:
                return .none
            }

        }
    }
}

extension TimerReducer.State {
    static var previews: TimerReducer.State {
        return .standard(StandardTimerReducer.State(timer: .init(), project: .init()))
    }
}
