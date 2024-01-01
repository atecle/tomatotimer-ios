import Foundation

struct TimerSessions: Equatable {

    // MARK: - Properties

    var currentSession: SessionType
    var timeLeftInCurrentSession: Int
    let workSessionLength: Int
    let shortBreakLength: Int
    let longBreakLength: Int
    let numberOfTimerSessions: Int
    var completedSessionsCount: Int // A entire session is a work plus a break.

    // MARK: - Computed Properties

    var isCurrentSessionComplete: Bool {
        return timeLeftInCurrentSession == 0
    }

    var totalSecondsInCurrentSession: Int {
        switch currentSession {
        case .work:
            return workSessionLength
        case .shortBreak:
            return shortBreakLength
        case .longBreak:
            return longBreakLength
        }
    }

    // This is how much time is left, from the current time, to the end of the timer. Used in setTimeElapsed logic
    var totalSecondsInTimerLeft: Int {
        var totalSeconds = timeLeftInCurrentSession
        var currentSessionIndex = completedSessionsCount + (self.currentSession.isBreak ? 1 : 0)
        currentSessionIndex += 1 // increment one because we already have the current session's seconds counted
        let totalSessionIndices = numberOfTimerSessions * 2
        while currentSessionIndex != totalSessionIndices {
            if currentSessionIndex.isEven {
                totalSeconds += workSessionLength
            } else if currentSessionIndex.isOdd && currentSessionIndex != (totalSessionIndices - 1) {
                totalSeconds += shortBreakLength
            } else {
                totalSeconds += longBreakLength
            }
            currentSessionIndex += 1
        }

        return totalSeconds
    }

    // MARK: - Initialization

    init(
        currentSession: SessionType = .work,
        timeLeftInCurrentSession: Int = 60,
        workSessionLength: Int = 60,
        shortBreakLength: Int = 60,
        longBreakLength: Int = 60,
        numberOfTimerSessions: Int = 4,
        completedSessionsCount: Int = 0
    ) {
        self.currentSession = currentSession
        self.timeLeftInCurrentSession = timeLeftInCurrentSession
        self.workSessionLength = workSessionLength
        self.shortBreakLength = shortBreakLength
        self.longBreakLength = longBreakLength
        self.numberOfTimerSessions = numberOfTimerSessions
        self.completedSessionsCount = completedSessionsCount
    }

}

struct TomatoTimer: Equatable {

    // MARK: - Properties

    let id: UUID

    var isRunning: Bool

    var timerSessions: TimerSessions

    var creationDate: Date

    var shouldAutostartNextBreakSession: Bool

    var shouldAutostartNextWorkSession: Bool

    // MARK: - Computed Properties

    var isResetTimer: Bool {
        return completedSessionsCount == 0 && hasBegun == false
    }

    var sessionsCount: Int {
        timerSessions.numberOfTimerSessions
    }

    var completedSessionsCount: Int {
        timerSessions.completedSessionsCount
    }

    var secondsLeftInCurrentSession: Int {
        get {
            timerSessions.timeLeftInCurrentSession
        } set {
            timerSessions.timeLeftInCurrentSession = newValue
        }
    }

    var totalSecondsInCurrentSession: Int {
        timerSessions.totalSecondsInCurrentSession
    }

    var hasBegun: Bool {
        timerSessions.timeLeftInCurrentSession != timerSessions.totalSecondsInCurrentSession
    }

    var currentSession: SessionType {
        timerSessions.currentSession
    }

    var isLastSession: Bool {
        timerSessions.currentSession == .longBreak
    }

    var nextSession: SessionType {
        return calculateNextSession()
    }

    private var isCurrentSessionComplete: Bool {
        return timerSessions.isCurrentSessionComplete
    }

    var continueRunningAfterSessionCompletion: Bool {
        switch currentSession {
        case .work:
            return shouldAutostartNextBreakSession
        default:
            return shouldAutostartNextWorkSession
        }
    }

    var config: TomatoTimerConfiguration

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        config: TomatoTimerConfiguration = TomatoTimerConfiguration(),
        creationDate: Date = .init()
    ) {
        self.id = id
        self.isRunning = false
        self.timerSessions = TimerSessions(
            currentSession: .work,
            timeLeftInCurrentSession: config.totalSecondsInWorkSession,
            workSessionLength: config.totalSecondsInWorkSession,
            shortBreakLength: config.totalSecondsInShortBreakSession,
            longBreakLength: config.totalSecondsInLongBreakSession,
            numberOfTimerSessions: config.numberOfTimerSessions,
            completedSessionsCount: 0
        )
        self.shouldAutostartNextWorkSession = config.shouldAutostartNextWorkSession
        self.shouldAutostartNextBreakSession = config.shouldAutostartNextBreakSession
        self.creationDate =  creationDate
        self.config = config
    }

    // MARK: - Methods

    mutating func decrementTime() {
        guard !isCurrentSessionComplete else {
            return complete()
        }

        timerSessions.timeLeftInCurrentSession -= 1
    }

    mutating func complete() {
        if !continueRunningAfterSessionCompletion {
            isRunning = false
        }

        timerSessions.currentSession = calculateNextSession()

        switch timerSessions.currentSession {
        case .work:
            timerSessions.timeLeftInCurrentSession = timerSessions.workSessionLength
            let allSessionsComplete = timerSessions.completedSessionsCount == timerSessions.numberOfTimerSessions - 1
            timerSessions.completedSessionsCount = allSessionsComplete
                ? 0
                : timerSessions.completedSessionsCount + 1
            isRunning = allSessionsComplete ? false : isRunning
        case .shortBreak:
            timerSessions.timeLeftInCurrentSession = timerSessions.shortBreakLength
        case .longBreak:
            timerSessions.timeLeftInCurrentSession = timerSessions.longBreakLength
        }
    }

    private func calculateNextSession() -> SessionType {
        switch currentSession {
        case .work:
            return timerSessions.completedSessionsCount == timerSessions.numberOfTimerSessions - 1 ? .longBreak : .shortBreak
        case .shortBreak:
            return .work
        case .longBreak:
            return .work
        }
    }

    // swiftlint:disable line_length
    mutating func setTimeElapsed(_ elapsed: Int) {
        print("================== setting time elapsed \(elapsed) || Current Time \(currentSession) - \(DateComponentsFormatter.formatted(self.secondsLeftInCurrentSession))")
        let timeLeftInSessionAfterElapsed = self.secondsLeftInCurrentSession - elapsed

        // A positive value means that the current session hasn't finished, so we can just
        // set the current time to (timeLeft - elapsed)
        guard timeLeftInSessionAfterElapsed <= 0 else {
            secondsLeftInCurrentSession = timeLeftInSessionAfterElapsed
            print("================== Set elapsed Current Time \(currentSession) - \(DateComponentsFormatter.formatted(self.secondsLeftInCurrentSession))")
            return
        }

        // If the elapsed time is greater than the total time in the entire timer
        // We should just reset the timer and set isRunning to false
        guard elapsed < timerSessions.totalSecondsInTimerLeft else {
            restartTimer()
            isRunning = false
            print("================== Set elapsed Current Time \(currentSession) - \(DateComponentsFormatter.formatted(self.secondsLeftInCurrentSession))")
            return
        }

        var elapsed = elapsed
        elapsed = elapsed - self.secondsLeftInCurrentSession
        // Otherwise, we're somewhere after the current session. So complete
        complete()

        // If we completed, and the timer is no longer running, that means we
        // the config either doesn't autostart, or we just completed the entire timer
        if !isRunning {
            print("================== Set elapsed Current Time \(currentSession) - \(DateComponentsFormatter.formatted(self.secondsLeftInCurrentSession))")
            return
        }

        // If we're at this point, that means that we have to calculate where in the timer progression we are.

        while elapsed - secondsLeftInCurrentSession >= 0 {
            elapsed = elapsed - secondsLeftInCurrentSession
            complete()
        }

        secondsLeftInCurrentSession -= elapsed
        print("================== Set elapsed Current Time \(currentSession) - \(DateComponentsFormatter.formatted(self.secondsLeftInCurrentSession))")
    }
    // swiftlint:enable line_length

    mutating func update(with config: TomatoTimerConfiguration) {
        if willBeReset(by: config) {
            let newConfig = TomatoTimer(id: id, config: config, creationDate: creationDate)

            self = newConfig
            self.isRunning = false
            return
        }

        shouldAutostartNextWorkSession = config.shouldAutostartNextWorkSession
        shouldAutostartNextBreakSession = config.shouldAutostartNextBreakSession
        self.config.shouldAutostartNextWorkSession = config.shouldAutostartNextWorkSession
        self.config.shouldAutostartNextBreakSession = config.shouldAutostartNextBreakSession
    }

    private func willBeReset(by config: TomatoTimerConfiguration) -> Bool {
        return config.totalSecondsInWorkSession != timerSessions.workSessionLength
            || config.totalSecondsInShortBreakSession != timerSessions.shortBreakLength
            || config.totalSecondsInLongBreakSession != timerSessions.longBreakLength
            || config.numberOfTimerSessions != timerSessions.numberOfTimerSessions
    }

    mutating func restartTimer() {
        self = TomatoTimer(id: id, config: config, creationDate: creationDate)
    }

    mutating func restartSession() {
        secondsLeftInCurrentSession = totalSecondsInCurrentSession
    }
}
