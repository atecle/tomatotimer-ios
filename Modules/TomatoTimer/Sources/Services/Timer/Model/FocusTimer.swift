import Foundation

extension FocusTimer {

    init() {
        self = .standard(.init())
    }
}

enum FocusTimer: Equatable {
    case standard(StandardTimer)
    case stopwatch(StopwatchTimer)

    var isStandard: Bool {
        switch self {
        case .standard: return true
        default: return false
        }
    }

    var isRunning: Bool {
        get {
            switch self {
            case let .standard(timer): return timer.isRunning
            case let .stopwatch(timer): return timer.isRunning
            }
        }
        set {
            switch self {
            case var .standard(timer):
                timer.isRunning = newValue
                self = .standard(timer)
            case var .stopwatch(timer):
                timer.isRunning = newValue
                self = .stopwatch(timer)
            }
        }
    }

    var wasStarted: Bool {
        get {
            switch self {
            case let .standard(timer): return timer.wasStarted
            case let .stopwatch(timer): return timer.hasBegun
            }
        }
        set {
            switch self {
            case var .standard(timer):
                timer.wasStarted = newValue
                self = .standard(timer)
            case var .stopwatch(timer):
                timer.hasBegun = newValue
                self = .stopwatch(timer)
            }
        }
    }

    var isComplete: Bool {
        get {
            switch self {
            case let .standard(timer): return timer.isComplete
            case let .stopwatch(timer): return timer.isComplete
            }
        }
        set {
            switch self {
            case var .standard(timer):
                timer.isComplete = newValue
                self = .standard(timer)
            case var .stopwatch(timer):
                timer.isComplete = newValue
                print("====================== new val \(newValue)")
                self = .stopwatch(timer)
            }
        }
    }

    var completedSessionCount: Int {
        switch self {
        case let .standard(timer):
            return timer.completedSessionCount
        case .stopwatch:
            return 0
        }
    }

    var autostartWorkSession: Bool {
        get {
            switch self {
            case let .standard(timer):
                return timer.config.autostartWorkSession
            case .stopwatch:
                return false
            }
        } set {
            switch self {
            case var .standard(timer):
                timer.config.autostartWorkSession = newValue
                self = .standard(timer)
            case .stopwatch:
                return
            }
        }
    }

    var autostartBreakSession: Bool {
        get {
            switch self {
            case let .standard(timer):
                return timer.config.autostartBreakSession
            case .stopwatch:
                return false
            }
        } set {
            switch self {
            case var .standard(timer):
                timer.config.autostartBreakSession = newValue
                self = .standard(timer)
            case .stopwatch:
                return
            }
        }
    }

    var currentSession: TimerSessionType {
        switch self {
        case let .standard(timer): return .standard(timer.currentSession)
        case let .stopwatch(timer): return .stopwatch(timer.currentSession)
        }
    }

    var totalTimeElapsed: Int {
        return totalWorkSecondsElapsed + totalBreakSecondsElapsed
    }

    var totalWorkSecondsElapsed: Int {
        switch self {
        case let .standard(timer): return timer.totalWorkTime
        case let .stopwatch(timer): return timer.workTime
        }
    }

    var totalBreakSecondsElapsed: Int {
        switch self {
        case let .standard(timer): return timer.totalBreakTime
        case let .stopwatch(timer): return timer.breakTime
        }
    }

    var timeDisplayString: String {
        switch self {
        case let .standard(timer): return DateComponentsFormatter.formatted(timer.timeLeftInSession)
        case let .stopwatch(timer): return timer.timeDisplayString
        }
    }

    var sessionProgressDisplayString: String {
        switch self {
        case let .standard(timer): return "\(timer.completedSessionCount + 1)/\(timer.config.sessionCount)"
        case .stopwatch: return ""
        }
    }

    var timeLeftInSession: Int {
        switch self {
        case let .standard(timer): return timer.timeLeftInSession
        case .stopwatch: return -1
        }
    }

    var sessionLength: Int {
        switch self {
        case let .standard(timer): return timer.sessionLength
        case .stopwatch: return -1
        }
    }

    var hasBegun: Bool {
        switch self {
        case let .standard(timer): return timer.hasBegun
        case .stopwatch: return false
        }
    }

    var isLastSession: Bool {
        switch self {
        case let .standard(timer): return timer.isLongBreak
        case .stopwatch: return false
        }
    }

    mutating func timerTick() {
        switch self {
        case var .standard(t):
            t.decrementTime()
            self = .standard(t)
        case var .stopwatch(timer):
            timer.incrementTime()
            self = .stopwatch(timer)
        }
    }

    mutating func setActiveSession(_ index: Int) {
        switch self {
        case var .standard(timer):
            timer.setActiveSession(index)
            self = .standard(timer)
        default:
            return
        }
    }

    mutating func pause() {
        switch self {
        case var .standard(timer):
            timer.pause()
            self = .standard(timer)
        case var .stopwatch(timer):
            timer.pause()
            self = .stopwatch(timer)
        }
    }

    mutating func removeSession(decrementCompleted: Bool) {
        switch self {
        case var .standard(timer):
            timer.removeSession(decrementCompleted: decrementCompleted)
            self = .standard(timer)
        default:
            return
        }
    }

    mutating func restart() {
        switch self {
        case var .standard(timer):
            timer.restartTimer()
            self = .standard(timer)
        case var .stopwatch(timer):
            timer.restartTimer()
            self = .stopwatch(timer)
        }
    }

    mutating func toggleSession() {
        switch self {
        case .standard:
            return
        case var .stopwatch(timer):
            timer.toggleSession()
            self = .stopwatch(timer)
        }
    }

    mutating func restartSession() {
        switch self {
        case var .standard(timer):
            timer.restartSession()
            self = .standard(timer)
        case var .stopwatch(timer):
            timer.restartSession()
            self = .stopwatch(timer)
        }
    }

    mutating func addSession() {
        switch self {
        case var .standard(timer):
            timer.addSession()
            self = .standard(timer)
        case .stopwatch:
            return
        }
    }

    mutating func complete() {
        switch self {
        case var .standard(timer):
            timer.complete()
            self = .standard(timer)
        case .stopwatch:
          return
        }
    }

    mutating func setTimeElapsed(_ elapsed: Int) {
        switch self {
        case var .standard(timer):
            timer.setTimeElapsed(elapsed)
            self = .standard(timer)
        case var .stopwatch(timer):
            timer.setTimeElapsed(elapsed)
            self = .stopwatch(timer)
        }
    }

    func newInstance(uuid: () -> UUID) -> FocusTimer {
        switch self {
        case let .standard(timer):
            return .standard(
                .init(
                    id: uuid(),
                    config: timer.config,
                    isRunning: timer.isRunning,
                    wasStarted: timer.wasStarted,
                    isComplete: timer.isComplete,
                    currentSession: timer.currentSession,
                    timeLeftInSession: timer.timeLeftInSession,
                    completedSessionCount: timer.completedSessionCount,
                    totalWorkTime: timer.totalWorkTime,
                    totalBreakTime: timer.totalBreakTime
                )
            )
        case let .stopwatch(timer):
            return .stopwatch(
                .init(
                    id: uuid(),
                    config: timer.config,
                    currentSession: timer.currentSession,
                    isRunning: timer.isRunning,
                    hasBegun: timer.hasBegun,
                    isComplete: timer.isComplete,
                    workTime: timer.workTime,
                    breakTime: timer.breakTime,
                    elapsedWorkTime: timer.elapsedWorkTime,
                    elapsedBreakTime: timer.elapsedBreakTime
                )
            )
        }
    }
}

extension FocusTimer {
    static var previews: FocusTimer {
        return .standard(
            StandardTimer(
                config: .init()
            )
        )
    }
}

extension FocusTimer {

    var totalElapsedTimeString: String {
        switch self {
        case let .standard(timer):
            return DateComponentsFormatter.formatted(timer.totalTime, includeHour: true)
        case let .stopwatch(timer):
            return DateComponentsFormatter.formatted(timer.totalTime, includeHour: true)
        }
    }

    var totalWorkTimeString: String {
        switch self {
        case let .standard(timer):
            return DateComponentsFormatter.formatted(timer.totalWorkTime, includeHour: true)
        case let .stopwatch(timer):
            return DateComponentsFormatter.formatted(timer.workTime, includeHour: true)
        }
    }

    var totalBreakTimeString: String {
        switch self {
        case let .standard(timer):
            return DateComponentsFormatter.formatted(timer.totalBreakTime, includeHour: true)
        case let .stopwatch(timer):
            return DateComponentsFormatter.formatted(timer.breakTime, includeHour: true)
        }
    }
}
