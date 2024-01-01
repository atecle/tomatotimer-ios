import Foundation

struct StandardTimerConfiguration: Equatable {

    var workSessionLength: Int
    var shortBreakLength: Int
    var longBreakLength: Int
    var sessionCount: Int
    var autostartWorkSession: Bool
    var autostartBreakSession: Bool
    var workSound: NotificationSound
    var breakSound: NotificationSound

    init(
        workSessionLength: Int = 60 * 25,
        shortBreakLength: Int = 60 * 5,
        longBreakLength: Int = 60 * 15,
        sessionCount: Int = 4,
        autostartWorkSession: Bool = true,
        autostartBreakSession: Bool = true,
        workSound: NotificationSound = .bell,
        breakSound: NotificationSound = .bell
    ) {
        self.workSessionLength = workSessionLength
        self.shortBreakLength = shortBreakLength
        self.longBreakLength = longBreakLength
        self.sessionCount = sessionCount
        self.autostartWorkSession = autostartWorkSession
        self.autostartBreakSession = autostartBreakSession
        self.workSound = workSound
        self.breakSound = breakSound
    }
}

struct StandardTimer: Equatable {

    // MARK: - Properties

    let id: UUID
    var config: StandardTimerConfiguration
    var isRunning: Bool {
        didSet {
            if isRunning == true, wasStarted == false {
                wasStarted = true
            }
        }
    }
    var timeLeftInSession: Int
    var currentSession: SessionType
    var completedSessionCount: Int
    var isComplete: Bool {
        didSet {
            if isComplete, isRunning {
                isRunning = false
            }
        }
    }
    var wasStarted: Bool
    var totalWorkTime: Int
    var totalBreakTime: Int

    // MARK: Computed

    var hasBegun: Bool {
        timeLeftInSession != sessionLength
    }

    var isLongBreak: Bool { currentSession == .longBreak }

    var isPristine: Bool {
        currentSession == .work && !hasBegun && completedSessionCount == 0 && isRunning == false
    }

    var isLastSession: Bool {
        isLongBreak ||
        (currentSession == .work && completedSessionCount == config.sessionCount - 2)
    }

    var totalTime: Int { totalWorkTime + totalBreakTime }

    // This is how much time is left, from the current time, to the end of the timer. Used in setTimeElapsed logic
    var totalSecondsInTimerLeft: Int {
        var totalSeconds = timeLeftInSession
        var currentSessionIndex = completedSessionCount + (self.currentSession.isBreak ? 1 : 0)
        currentSessionIndex += 1 // increment one because we already have the current session's seconds counted
        let totalSessionIndices = config.sessionCount * 2
        while currentSessionIndex != totalSessionIndices {
            if currentSessionIndex.isEven {
                totalSeconds += config.workSessionLength
            } else if currentSessionIndex.isOdd && currentSessionIndex != (totalSessionIndices - 1) {
                totalSeconds += config.shortBreakLength
            } else {
                totalSeconds += config.longBreakLength
            }
            currentSessionIndex += 1
        }

        return totalSeconds
    }

    var sessionLength: Int {
        switch currentSession {
        case .work:
            return config.workSessionLength
        case .shortBreak:
            return config.shortBreakLength
        case .longBreak:
            return config.longBreakLength
        }
    }

    var isCurrentSessionComplete: Bool {
        timeLeftInSession == 0
    }

    var continueRunningAfterSessionCompletion: Bool {
        switch currentSession {
        case .work:
            return config.autostartBreakSession
        default:
            return config.autostartWorkSession
        }
    }

    private var nextSession: SessionType {
        switch currentSession {
        case .work:
            return completedSessionCount == config.sessionCount - 1 ? .longBreak : .shortBreak
        case .shortBreak:
            return .work
        case .longBreak:
            return .work
        }
    }

    var timeDisplayString: String {
        return DateComponentsFormatter.formatted(timeLeftInSession)
    }

    var sessionProgressDisplayString: String {
        return "\(completedSessionCount + 1)/\(config.sessionCount)"
    }

    // MARK: - Methods

    // MARK: Init

    init(
        id: UUID = UUID(),
        config: StandardTimerConfiguration = .init(),
        isRunning: Bool = false,
        wasStarted: Bool = false,
        isComplete: Bool = false,
        currentSession: SessionType = .work,
        timeLeftInSession: Int? = nil,
        completedSessionCount: Int = 0,
        totalWorkTime: Int = 0,
        totalBreakTime: Int = 0
    ) {
        self.id = id
        self.config = config
        self.isRunning = isRunning
        self.wasStarted = wasStarted
        self.isComplete = isComplete
        self.timeLeftInSession = timeLeftInSession ?? config.workSessionLength
        self.currentSession = currentSession
        self.completedSessionCount = completedSessionCount
        self.totalWorkTime = totalWorkTime
        self.totalBreakTime = totalBreakTime
    }

    mutating func decrementTime() {
        guard !isCurrentSessionComplete else {
            return complete()
        }

        if currentSession.isBreak {
            totalBreakTime += 1
        } else {
            totalWorkTime += 1
        }

        timeLeftInSession -= 1
    }

    mutating func complete() {
        if !continueRunningAfterSessionCompletion {
            isRunning = false
        }

        currentSession = nextSession

        switch currentSession {
        case .work:
            timeLeftInSession = config.workSessionLength

            if completedSessionCount == config.sessionCount - 1 {
                completedSessionCount = 0
                isRunning = false
                isComplete = true
            } else if currentSession == .work {
                completedSessionCount += 1
            }
        case .shortBreak:
            timeLeftInSession = config.shortBreakLength
        case .longBreak:
            timeLeftInSession = config.longBreakLength
        }

    }

    mutating func restartTimer() {
        self = StandardTimer(id: id, config: config, totalWorkTime: totalWorkTime, totalBreakTime: totalBreakTime)
    }

    mutating func restartSession() {
        switch currentSession {
        case .work:
            timeLeftInSession = config.workSessionLength
        case .shortBreak:
            timeLeftInSession = config.shortBreakLength
        case .longBreak:
            timeLeftInSession = config.longBreakLength
        }
    }

    mutating func update(with config: StandardTimerConfiguration) {
        if willBeReset(by: config) {
            let newConfig = StandardTimer(id: id, config: config, totalWorkTime: totalWorkTime, totalBreakTime: totalBreakTime)
            self = newConfig
            self.isRunning = false
            return
        }

        self.config.autostartWorkSession = config.autostartWorkSession
        self.config.autostartBreakSession = config.autostartBreakSession
    }

    private func willBeReset(by config: StandardTimerConfiguration) -> Bool {
        return config.workSessionLength != self.config.workSessionLength
        || config.shortBreakLength != self.config.shortBreakLength
        || config.longBreakLength != self.config.longBreakLength
        || config.sessionCount != self.config.sessionCount
    }

    mutating func update(from list: SessionList, setWorkSession: Bool) {
        config.sessionCount = list.tasks.count
        completedSessionCount = list.tasks.filter(\.completed).count
        if completedSessionCount == list.tasks.count {
            completedSessionCount = 0
            isComplete = true
        }
        currentSession = setWorkSession ? .work : currentSession
    }

    mutating func update(from list: FocusList, setWorkSession: Bool) {
        switch list {
        case let .session(list):
            update(from: list, setWorkSession: setWorkSession)
        default:
            return
        }
    }

    mutating func addSession() {
        config.sessionCount += 1
    }

    mutating func removeSession(decrementCompleted: Bool) {
        config.sessionCount -= 1
        if decrementCompleted {
            completedSessionCount -= 1
        }
    }

    mutating func setActiveSession(_ index: Int) {
        guard index >= 0, index < config.sessionCount else {
            restartTimer()
            return
        }
        completedSessionCount = index
        currentSession = .work
        timeLeftInSession = config.workSessionLength
    }

    mutating func setTimeElapsed(_ elapsed: Int) {
        let timeLeftInSessionAfterElapsed = self.timeLeftInSession - elapsed

        // A positive value means that the current session hasn't finished, so we can just
        // set the current time to (timeLeft - elapsed)
        guard timeLeftInSessionAfterElapsed <= 0 else {
            for _ in (0...elapsed) {
                decrementTime()
            }
            return
        }

        // If the elapsed time is greater than the total time in the entire timer
        // We should just reset the timer and set isRunning to false
        guard elapsed < totalSecondsInTimerLeft else {
            for _ in (0...totalSecondsInTimerLeft) {
                decrementTime()
            }
            isRunning = false
            return
        }

        var elapsed = elapsed
        elapsed = elapsed - self.timeLeftInSession
        // Otherwise, we're somewhere after the current session. So complete
        for _ in (0...timeLeftInSession) {
            decrementTime()
        }

        // If we completed, and the timer is no longer running, that means we
        // the config either doesn't autostart, or we just completed the entire timer
        if !isRunning {
            return
        }

        // If we're at this point, that means that we have to calculate where in the timer progression we are.

        while elapsed - timeLeftInSession >= 0 {
            elapsed = elapsed - timeLeftInSession
            for _ in (0...timeLeftInSession) {
                decrementTime()
            }
        }

        for _ in (0...elapsed) {
            decrementTime()
        }
    }

    mutating func pause() {
        isRunning = false
    }
}
