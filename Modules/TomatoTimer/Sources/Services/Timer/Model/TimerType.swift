import Foundation

enum TimerType: String, Equatable, CaseIterable {
    case standard
    case stopwatch
}

extension FocusTimer {
    var type: TimerType {
        switch self {
        case .standard: return .standard
        case .stopwatch: return .stopwatch
        }
    }
}
