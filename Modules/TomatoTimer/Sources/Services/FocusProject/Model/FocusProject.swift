import Foundation
import UIKit

// swiftlint:disable:next type_body_length
struct FocusProject: Equatable {
    var id: UUID
    let creationDate: Date
    var scheduledDate: Date
    var title: String
    var emoji: String
    var list: FocusList
    var themeColorString: String
    var themeColor: UIColor {
        get {
            UIColor(themeColorString)
        }
        set {
            themeColorString = newValue.hexString()
        }

    }
    var timer: FocusTimer
    var isActive: Bool

    // It's either or - need to fix because it makes the code complicated - see editing logic
    var recurrence: Recurrence?
    var recurrenceTemplate: Recurrence?

    var isRecurrenceTemplate: Bool { recurrenceTemplate != nil }
    var isRecurringInstance: Bool { recurrence != nil }

    var activityGoals: [ActivityGoal]

    var recurrenceString: String {
        (recurrence?.recurrenceString ?? recurrenceTemplate?.recurrenceString) ?? ""
    }

    var totalWorkSecondsElapsed: Int { timer.totalWorkSecondsElapsed }
    var totalBreakSecondsElapsed: Int { timer.totalBreakSecondsElapsed }
    var totalTimeElapsed: Int { totalWorkSecondsElapsed + totalBreakSecondsElapsed }

    init(
        id: UUID = UUID(),
        title: String = "",
        creationDate: Date = Date(),
        scheduledDate: Date = Date(),
        emoji: String = randomEmoji(),
        themeColor: UIColor = UIColor.appPomodoroRed,
        list: FocusList = .singleTask(.init()),
        timer: FocusTimer = .standard(.init()),
        isActive: Bool = false,
        recurrence: Recurrence? = nil,
        recurrenceTemplate: Recurrence? = nil,
        activityGoals: [ActivityGoal] = []
    ) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.scheduledDate = scheduledDate
        self.emoji = emoji
        self.list = list
        self.themeColorString = themeColor.hexString()
        self.timer = timer
        self.isActive = isActive
        self.recurrence = recurrence
        self.recurrenceTemplate = recurrenceTemplate
        self.activityGoals = activityGoals
    }

    mutating func completeCurrentTask() {
        list.completeCurrentTask()
        switch (list, timer) {
        case (.session, .standard(var standardTimer)):
            standardTimer.update(from: list, setWorkSession: standardTimer.currentSession.isBreak)
            self.timer = .standard(standardTimer)
        default:
            if self.list.incompleteTaskCount == 0 && (!self.list.isNone) {
                self.timer.pause()
            }

        }

        if !list.isNone && list.allComplete {
            self.timer.isRunning = false
        }
    }

    mutating func updateTask(_ task: FocusListTask, title: String) {
        switch list {
        case var .singleTask(list):
            list.task?.title = title
            self.list = .singleTask(list)
        case var .standard(list):
            for index in list.tasks.indices where list.tasks[index].id == task.id {
                list.tasks[index].title = title
            }
            self.list = .standard(list)
        case var .session(list):
            for index in list.tasks.indices where list.tasks[index].id == task.id {
                list.tasks[index].title = title
            }
            self.list = .session(list)
        case .none:
            return
        }
    }

    // swiftlint:disable:next function_body_length
    mutating func toggleCompleted(task: FocusListTask) {
        switch list {
        case var .standard(list):
            guard let index = list.tasks.firstIndex(where: { $0.id == task.id }) else { return  }
            let wasInProgress = list.tasks[index].inProgress
            list.tasks[index].completed.toggle()
            list.tasks[index].inProgress = false
            if wasInProgress {
                guard let next = list.tasks.nextIndex(startingAt: index, where: { $0.completed == false }) else {
                    self.list = .standard(list)
                    return
                }
                list.tasks[next].inProgress = true
            }

            if list.tasks[index].completed == false && list.tasks.filter({ $0.inProgress }).count == 0 {
                list.tasks[index].inProgress = true
            }
            self.list = .standard(list)
        case var .session(list):
            guard let indexOfTask = list.tasks.firstIndex(where: { $0.id == task.id }) else { return }
            let wasComplete = list.tasks[indexOfTask].completed
            if !task.completed && task == list.tasks.last {
                for index in list.tasks.indices {
                    list.tasks[index].completed = true
                    list.tasks[index].inProgress = false
                }
            } else if !task.completed {
                for index in list.tasks.indices {
                    if list.tasks[index].id == task.id {
                        list.tasks[index].completed = true
                        list.tasks[index].inProgress = false
                        if list.tasks.indices.contains(index + 1), !list.tasks[index+1].completed {
                            list.tasks[index + 1].inProgress = true
                        }
                        break
                    } else {
                        list.tasks[index].completed = true
                        list.tasks[index].inProgress = false
                    }
                }
            } else {
                for index in list.tasks.indices.reversed() {
                    if list.tasks[index].id == task.id {
                        list.tasks[index].completed = false
                        list.tasks[index].inProgress = true
                        break
                    } else {
                        list.tasks[index].completed = false
                        list.tasks[index].inProgress = false
                    }
                }
            }

            self.list = .session(list)
            self.timer.setActiveSession(wasComplete ? indexOfTask : indexOfTask + 1)
            self.timer.isComplete = list.tasks.allSatisfy(\.completed)

        case var .singleTask(list):
            guard list.task?.id == task.id else { return }
            list.task = nil
            self.list = .singleTask(list)
        case .none:
            return
        }
    }

    mutating func uncomplete() {
        timer.isComplete = false
        switch list {
        case var .session(list):
            for index in list.tasks.indices {
                list.tasks[index].inProgress = index == 0
                list.tasks[index].completed = false
            }
            self.list = .session(list)
        default:
            break
        }
    }

    mutating func addTask(task: FocusListTask) {
        var task = task
        switch list {
        case var .singleTask(list):
            list.task = task
            self.list = .singleTask(list)
        case .standard:
            task.order = list.tasks.count
            self.list = .standard(.init(id: list.id, tasks: list.tasks + [task]))
        case .session:
            task.order = list.tasks.count
            self.list = .session(.init(id: list.id, tasks: list.tasks + [task]))
            timer.addSession()
        case .none:
            return
        }
    }

    mutating func delete(task: FocusListTask) {
        switch list {
        case var .singleTask(list):
            list.task = nil
            self.list = .singleTask(list)
        case var .standard(list):
            list.tasks.removeAll(where: { task.id == $0.id })
            self.list = .standard(list)
        case var .session(list):
            guard let indexToBeDeleted = list.tasks.firstIndex(where: { $0.id == task.id }) else { return }
            let wasInProgress = list.tasks[indexToBeDeleted].inProgress
            let wasComplete = list.tasks[indexToBeDeleted].completed
            if wasInProgress, let nextIndexInProgress = list.tasks.nextIndex(startingAt: indexToBeDeleted, where: { !$0.completed }) {
                list.tasks[nextIndexInProgress].inProgress = true
            }
            list.tasks.remove(at: indexToBeDeleted)
            self.list = .session(list)
            timer.removeSession(decrementCompleted: wasComplete)
        case .none:
            return
        }
    }

    mutating func markInProgress(task: FocusListTask) {
        switch list {
        case var .singleTask(list):
            list.task = task
            self.list = .singleTask(list)
        case var .standard(list):
            for index in list.tasks.indices {
                if list.tasks[index].id == task.id {
                    list.tasks[index].inProgress = true
                } else {
                    list.tasks[index].inProgress = false
                }
            }
            self.list = .standard(list)
        case var .session(list):
            guard let indexOfTask = list.tasks.firstIndex(where: { $0.id == task.id }) else { return }
            for index in list.tasks.indices {
                if list.tasks[index].id == task.id {
                    list.tasks[index].inProgress = true
                    list.tasks[index].completed = false
                } else if index > indexOfTask {
                    list.tasks[index].completed = false
                    list.tasks[index].inProgress = false
                } else {
                    list.tasks[index].completed = true
                    list.tasks[index].inProgress = false
                }
            }

            self.list = .session(list)
            self.timer.setActiveSession(indexOfTask)
        case .none:
            return
        }
    }

    mutating func restartTimer() {
        timer.restart()
        switch list {
        case var .session(list):
            for index in list.tasks.indices {
                list.tasks[index].inProgress = index == 0
                list.tasks[index].completed = false
            }
            self.list = .session(list)
        default:
            return
        }
    }

    mutating func restartTimerSession() {
        timer.restartSession()
        switch list {
        case .session:
            return
        default:
            return
        }
    }

    mutating func completeTimerSession() {
        timer.complete()
        switch list {
        case .session:
            if !timer.currentSession.isBreak {
                completeCurrentTask()
            }
            return
        default:
            return
        }
    }

    mutating func setTimeElapsed(_ elapsed: Int) {
        guard timer.isRunning else { return }
        timer.setTimeElapsed(elapsed)

        switch (timer, list) {
        case (.standard(let timer), .session(var list)):
            list.updateForCompletedSessionCount(timer.completedSessionCount)
            self.list = .session(list)
        default:
            return
        }
    }

    mutating func timerTick() {
        let wasBreak = timer.currentSession.isBreak
        timer.timerTick()
        switch list {
        case .session:
            if wasBreak, !timer.currentSession.isBreak {
                list.completeCurrentTask()
            }
        default:
            return
        }
    }

    mutating func toggleIsRunning() {
        switch timer {
        case var .standard(timer):
            timer.isRunning.toggle()
            self.timer = .standard(timer)
        case var .stopwatch(timer):
            timer.isRunning.toggle()
            self.timer = .stopwatch(timer)
        }
    }
}

extension FocusProject {
    static var standardTimerStandardListPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Standard Timer + Standard List",
            themeColor: .appOffBlack,
            list: .previews,
            timer: .standard(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var standardTimerSessionListPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Standard Timer + Session List",
            themeColor: .appBlue,
            list: .sessionPreviews,
            timer: .standard(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var standardTimerSingleTaskPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Standard Timer + Single Task",
            themeColor: .appCyan,
            list: .singleTask(.init()),
            timer: .standard(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var standardTimerNoListPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Standard Timer + No List",
            themeColor: .appPomodoroRed,
            list: .none,
            timer: .standard(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var stopwatchTimerStandardListPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Stopwatch Timer + Standard List",
            themeColor: .appRose,
            list: .previews,
            timer: .stopwatch(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var stopwatchTimerSingleTaskPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Stopwatch Timer + Single Task",
            themeColor: .appIndigo,
            list: .singleTask(.init()),
            timer: .stopwatch(
                .init(
                    config: .init()
                )
            )
        )
    }

    static var stopwatchTimerNoListPreview: FocusProject {
        .init(
            id: UUID(),
            title: "Stopwatch Timer + No List",
            themeColor: .appGreen,
            list: .none,
            timer: .stopwatch(
                .init(
                    config: .init()
                )
            )
        )
    }

}

extension FocusProject: Identifiable { }

extension FocusProject {
    var totalTasksCompleteString: String {
        return "\(list.tasks.filter(\.completed).count) / \(list.tasks.count)"
    }
}

extension FocusProject {
    struct Recurrence: Equatable {
        let id: UUID
        var templateProjectID: UUID
        var endDate: Date?
        var repeatingDays: Set<WeekDay>
        var reminderDate: Date?

        var recurrenceString: String {
            guard repeatingDays.count != 7 else {
                return "Everyday"
            }
            let days = Array(repeatingDays).sorted(by: \.sortOrder)
            return days.map(\.abbreviation).joined(separator: " ")
        }

        var isEveryday: Bool {
            repeatingDays.count == 7
        }

        init(
            id: UUID = UUID(),
            templateProjectID: UUID = UUID(),
            repeatingDays: Set<WeekDay> = WeekDay.everyday,
            endDate: Date? = nil,
            reminderDate: Date? = nil
        ) {
            self.id = id
            self.templateProjectID = templateProjectID
            self.endDate = endDate
            self.repeatingDays = repeatingDays
            self.reminderDate = reminderDate
        }
    }
}
