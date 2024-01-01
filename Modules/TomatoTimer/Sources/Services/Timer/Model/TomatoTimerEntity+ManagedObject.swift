import Foundation
import CoreData

extension TomatoTimerEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        []
    }

    func toNonManagedObject() -> TomatoTimer? {
        return TomatoTimer(entity: self)
    }

    func update(from timer: TomatoTimer, context: NSManagedObjectContext) {
        id = timer.id
        isRunning = timer.isRunning
        currentSession = Int64(timer.currentSession.rawValue)
        creationDate = timer.creationDate
        timeLeftInCurrentSession = Int64(timer.timerSessions.timeLeftInCurrentSession)
        workSessionLength = Int64(timer.timerSessions.workSessionLength)
        shortBreakLength = Int64(timer.timerSessions.shortBreakLength)
        longBreakLength = Int64(timer.timerSessions.longBreakLength)
        numberOfTimerSessions = Int64(timer.timerSessions.numberOfTimerSessions)
        completedSessionsCount = Int64(timer.timerSessions.completedSessionsCount)
        shouldAutostartNextWorkSession = timer.shouldAutostartNextWorkSession
        shouldAutostartNextBreakSession = timer.shouldAutostartNextBreakSession
    }
}

extension TomatoTimer {

    init?(entity: TomatoTimerEntity) {
        guard
            let id = entity.id,
            let creationDate = entity.creationDate,
            let currentSession = SessionType(rawValue: Int(entity.currentSession)) else {
            return nil
        }

        self.id = id
        self.creationDate = creationDate
        self.isRunning = entity.isRunning
        self.timerSessions = TimerSessions(
            currentSession: currentSession,
            timeLeftInCurrentSession: Int(entity.timeLeftInCurrentSession),
            workSessionLength: Int(entity.workSessionLength),
            shortBreakLength: Int(entity.shortBreakLength),
            longBreakLength: Int(entity.longBreakLength),
            numberOfTimerSessions: Int(entity.numberOfTimerSessions),
            completedSessionsCount: Int(entity.completedSessionsCount)
        )

        self.shouldAutostartNextBreakSession = entity.shouldAutostartNextBreakSession
        self.shouldAutostartNextWorkSession = entity.shouldAutostartNextWorkSession
        self.config = TomatoTimerConfiguration(
            totalSecondsInWorkSession: Int(entity.workSessionLength),
            totalSecondsInShortBreakSession: Int(entity.shortBreakLength),
            totalSecondsInLongBreakSession: Int(entity.longBreakLength),
            numberOfTimerSessions: Int(entity.numberOfTimerSessions),
            shouldAutostartNextWorkSession: entity.shouldAutostartNextWorkSession,
            shouldAutostartNextBreakSession: entity.shouldAutostartNextBreakSession
        )
    }
}
