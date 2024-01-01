import Foundation

enum TimerSessionType: Equatable {
    case standard(SessionType)
    case stopwatch(StopwatchTimerSessionType)

    var isBreak: Bool {
        switch self {
        case let .standard(type):
            return type.isBreak
        case let .stopwatch(type):
            return type == .break
        }
    }

    var isWork: Bool {
        !isBreak
    }

    var description: String {
        switch self {
        case let .standard(type):
            return type.description
        case let .stopwatch(type):
            return type.description
        }
    }
}

enum SessionType: Int, CustomStringConvertible {
    case work
    case shortBreak
    case longBreak

    var isBreak: Bool { self == .shortBreak || self == .longBreak }

    var description: String {
        switch self {
        case .work:
            return .workSession
        case .longBreak:
            return .longBreak
        case .shortBreak:
            return .shortBreak
        }
    }
}

enum StopwatchTimerSessionType: Int {
    case work
    case `break`

    var isBreak: Bool { self == .break }

    var description: String {
        switch self {
        case .work:
            return "Work Session"
        case .break:
            return "Break Session"
        }
    }
}
