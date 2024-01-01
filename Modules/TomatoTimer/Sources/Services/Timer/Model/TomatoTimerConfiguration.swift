import Foundation

struct TomatoTimerConfiguration: Equatable {
    var totalSecondsInWorkSession: Int
    var totalSecondsInShortBreakSession: Int
    var totalSecondsInLongBreakSession: Int
    var numberOfTimerSessions: Int
    var shouldAutostartNextWorkSession: Bool
    var shouldAutostartNextBreakSession: Bool

    init(
        totalSecondsInWorkSession: Int = 25 * 60,
        totalSecondsInShortBreakSession: Int = 5 * 60,
        totalSecondsInLongBreakSession: Int = 15 * 60,
        numberOfTimerSessions: Int = 4,
        shouldAutostartNextWorkSession: Bool = true,
        shouldAutostartNextBreakSession: Bool = true
    ) {
        self.totalSecondsInWorkSession = totalSecondsInWorkSession
        self.totalSecondsInShortBreakSession = totalSecondsInShortBreakSession
        self.totalSecondsInLongBreakSession = totalSecondsInLongBreakSession
        self.numberOfTimerSessions = numberOfTimerSessions
        self.shouldAutostartNextWorkSession = shouldAutostartNextWorkSession
        self.shouldAutostartNextBreakSession = shouldAutostartNextBreakSession
    }
}
