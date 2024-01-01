import Foundation

struct StopwatchTimerConfiguration: Equatable {}

struct StopwatchTimer: Equatable {

    // MARK: - Properties

    let id: UUID
    var config: StopwatchTimerConfiguration
    var currentSession: StopwatchTimerSessionType = .work
    var isRunning: Bool = false {
        didSet {
            if isRunning == true, hasBegun == false {
                hasBegun = true
            }
        }
    }
    var elapsedWorkTime: Int = 0
    var elapsedBreakTime: Int = 0
    var workTime: Int = 0
    var breakTime: Int = 0
    var hasBegun: Bool
    var isComplete: Bool {
        didSet {
            if isComplete, isRunning {
                isRunning = false
            }
        }
    }

    var totalTime: Int { workTime + breakTime }

    var time: Int {
        switch currentSession {
        case .work:
            return workTime
        case .break:
            return breakTime
        }
    }

    var timeDisplayString: String {
        switch currentSession {
        case .work:
            return DateComponentsFormatter.formatted(workTime)
        case .break:
            return DateComponentsFormatter.formatted(breakTime)
        }
    }

    // MARK: - Methods

    // MARK: Init

    init(
        id: UUID = UUID(),
        config: StopwatchTimerConfiguration = .init(),
        currentSession: StopwatchTimerSessionType = .work,
        isRunning: Bool = false,
        hasBegun: Bool = false,
        isComplete: Bool = false,
        workTime: Int = 0,
        breakTime: Int = 0,
        elapsedWorkTime: Int = 0,
        elapsedBreakTime: Int = 0
    ) {
        self.id = id
        self.config = config
        self.currentSession = currentSession
        self.isRunning = isRunning
        self.hasBegun = hasBegun
        self.isComplete = isComplete
        self.workTime = workTime
        self.breakTime = breakTime
        self.elapsedWorkTime = elapsedWorkTime
        self.elapsedBreakTime = elapsedBreakTime
    }

    // MARK: Timer

    mutating func incrementTime() {
        switch currentSession {
        case .work:
            workTime += 1
            elapsedWorkTime += 1
        case .break:
            breakTime += 1
            elapsedBreakTime += 1
        }
    }

    mutating func restartTimer() {
        currentSession = .work
        workTime = 0
        breakTime = 0
        isRunning = false
        hasBegun = false
    }

    mutating func restartSession() {
        switch currentSession {
        case .work:
            workTime = 0
        case .break:
            breakTime = 0
        }
    }

    mutating func toggleSession() {
        switch currentSession {
        case .work:
            currentSession = .break
        case .break:
            currentSession = .work
        }
    }

    mutating func toggleIsRunning() {
        isRunning.toggle()
    }

    mutating func pause() {
        isRunning = false
    }

    mutating func setTimeElapsed(_ elapsed: Int) {
        switch currentSession {
        case .work:
            workTime += elapsed
        case .break:
            breakTime += elapsed
        }
    }
}
