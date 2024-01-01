import Foundation
import UIKit

extension FocusList {
    init() {
        self = .standard(.init())
    }
}

enum FocusList: Equatable, CaseIterable, Identifiable {
    static var allCases: [FocusList] {
        [
            .standard(.init()),
            .session(.init()),
            .singleTask(.init()),
            .none
        ]
    }

    case standard(StandardList)
    case session(SessionList)
    case singleTask(SingleTaskList)
    case none

    var id: UUID {
        switch self {
        case let .standard(list):
            return list.id
        case let .session(list):
            return list.id
        case let .singleTask(list):
            return list.id
        case .none:
            return UUID(uuidString: "cf8b8ccd-eb7c-434e-a144-fc9a5cc33b4a")!
        }
    }

    var isStandard: Bool {
        switch self {
        case .standard: return true
        default: return false
        }
    }

    var isSingleTask: Bool {
        switch self {
        case .singleTask: return true
        default: return false
        }
    }

    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }

    var isSession: Bool {
        switch self {
        case .session: return true
        default: return false
        }
    }

    var allComplete: Bool {
        return tasks.filter(\.completed).count == tasks.count
    }

    var incompleteTaskCount: Int {
        guard !isNone else { return 1 } // This shouldn't live here probably. Makes it so timer is always active
        return tasks.filter { !$0.completed }.count
    }

    var tasks: [FocusListTask] {
        switch self {
        case let .standard(list):
            return list.tasks
        case let .session(list):
            return list.tasks
        case let .singleTask(list):
            return [list.task].compactMap { $0 }
        case .none:
            return []
        }
    }

    mutating func completeCurrentTask() {
        switch self {
        case var .standard(list):
            guard let indexOfCurrentTask = list.tasks.firstIndex(where: \.inProgress) else { return }
            list.tasks[indexOfCurrentTask].completed = true
            list.tasks[indexOfCurrentTask].inProgress = false
            guard let indexOfNextTask = list.tasks.nextIndex(startingAt: indexOfCurrentTask, where: { !$0.completed }) else {
                self = .standard(list)
                return
            }

            list.tasks[indexOfNextTask].inProgress = true
            self = .standard(list)

        case var .session(list):
            guard let indexOfCurrentTask = list.tasks.firstIndex(where: \.inProgress) else { return }
            list.tasks[indexOfCurrentTask].completed = true
            list.tasks[indexOfCurrentTask].inProgress = false
            guard let indexOfNextTask = list.tasks.nextIndex(startingAt: indexOfCurrentTask, where: { !$0.completed }) else {
                self = .session(list)
                return
            }

            list.tasks[indexOfNextTask].inProgress = true
            self = .session(list)

        case var .singleTask(list):
            list.task = nil
            self = .singleTask(list)
        case .none:
            break
        }

    }

    mutating func updateCurrentTask(with title: String) {
        switch self {
        case var .standard(list):
            guard let indexOfCurrentTask = list.tasks.firstIndex(where: \.inProgress) else { return }
            guard !title.isEmpty else {
                _ = list.tasks.remove(at: indexOfCurrentTask)
                self = .standard(list)
                return
            }
            list.tasks[indexOfCurrentTask].title = title
            self = .standard(list)

        case var .session(list):
            guard let indexOfCurrentTask = list.tasks.firstIndex(where: \.inProgress) else { return }
            guard !title.isEmpty else {
                _ = list.tasks.remove(at: indexOfCurrentTask)
                self = .session(list)
                return
            }
            list.tasks[indexOfCurrentTask].title = title
            self = .session(list)

        case var .singleTask(list):
            guard !title.isEmpty else {
                list.task = nil
                self = .singleTask(list)
                return
            }
            list.task?.title = title
            self = .singleTask(list)

        case .none:
            break
        }
    }

    func newInstance(uuid: () -> UUID) -> FocusList {
        switch self {
        case let .standard(list):
            return .standard(
                .init(
                    id: uuid(),
                    tasks: list.tasks.map { .init(id: uuid(), title: $0.title) }
                )
            )
        case let .session(list):
            return .session(
                .init(
                    id: uuid(),
                    tasks: list.tasks.map { .init(id: uuid(), title: $0.title) }
                )
            )
        case let .singleTask(list):
            return .singleTask(
                .init(
                    id: uuid(),
                    task: list.task == nil ? nil : .init(id: uuid(), title: list.task!.title)
                )
            )
        case .none:
            return .none
        }
    }
}

extension FocusList {
    static var previews: FocusList {
        .standard(.init(tasks: FocusListTask.previews))
    }

    static var sessionPreviews: FocusList {
        .session(.init(tasks: FocusListTask.previews))
    }
}
