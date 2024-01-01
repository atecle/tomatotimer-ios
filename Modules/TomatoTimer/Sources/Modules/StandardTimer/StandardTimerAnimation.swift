import Foundation

enum StandardTimerAnimation: Equatable {
    case pristineToStarted
    case startedToPristine(secondsLeft: Int, totalSeconds: Int)
    case finishedToPristine
    case refill(secondsLeft: Int, totalSeconds: Int)
    case completeAndContinue(secondsLeft: Int, totalSeconds: Int)
    case startNextSession

    var isStartedToPristine: Bool {
        switch self {
        case .startedToPristine: return true
        default: return false
        }
    }
}
