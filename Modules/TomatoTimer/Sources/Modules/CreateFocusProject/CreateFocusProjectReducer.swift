import Foundation
import ComposableArchitecture
import UIKit

// swiftlint:disable type_body_length file_length
struct CreateFocusProjectReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setDidPurchasePlus(Bool)

        case dismissButtonPressed
        case doneButtonPressed
        case timerTypeRowPressed
        case listTypeRowPressed
        case workSoundRowPressed
        case breakSoundRowPressed
        case setTitle(String)
        case setEmoji(String)
        case selectedThemeColor(UIColor)
        case setRepeats(Bool)
        case toggleDayRecurrence(WeekDay)
        case setAutostartWorkSession(Bool)
        case setAutostartBreakSession(Bool)
        case setWorkLength(Int)
        case setShortBreakLength(Int)
        case setLongBreakLength(Int)
        case setNumberOfSessions(Int)
        case setEndRepeat(Bool)
        case setEndRepeatDate(Date?)
        case setRemindersEnabled(Bool)
        case setReminderTime(Date)
        case selectActivityGoalButtonPressed
        case removeActivityGoal(ActivityGoal)
        case setSaving(Bool)

        // Presentation and Delegate
        case paywall(PresentationAction<PaywallReducer.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case didCreateProject
        }
    }

    struct State: Equatable {
        var project: FocusProject = .init()
        var didPurchasePlus: Bool = false
        var oldProject: FocusProject
        var isEditing: Bool = false
        var isSaving: Bool = false
        var path: StackState<Path.State> = .init()
        var recurrence: FocusProject.Recurrence?

        var canSave: Bool { !project.title.isEmpty }
        var repeats: Bool { !repeatingDays.isEmpty }
        var repeatingDays: Set<WeekDay> { recurrence?.repeatingDays ?? .init() }
        var endRepeat: Bool { recurrence?.endDate != nil }
        var endRepeatDate: Date? { recurrence?.endDate }
        var remindersEnabled: Bool { recurrence?.reminderDate != nil }
        var reminderDate: Date? { recurrence?.reminderDate }

        @PresentationState var paywall: PaywallReducer.State?

        init(
            project: FocusProject = .init(),
            isEditing: Bool = false
        ) {
            self.project = project
            self.oldProject = project
            self.recurrence = project.recurrenceTemplate ?? project.recurrence
            self.isEditing = isEditing
        }
    }

    struct Path: ReducerProtocol {
        enum Action: Equatable {
            case selectTimerType(SelectTimerTypeReducer.Action)
            case selectListType(SelectListTypeReducer.Action)
            case selectWorkSound(SelectNotificationSoundReducer.Action)
            case selectBreakSound(SelectNotificationSoundReducer.Action)
            case selectActivityGoal(SelectActivityGoalReducer.Action)
        }

        enum State: Equatable {
            case selectTimerType(SelectTimerTypeReducer.State)
            case selectListType(SelectListTypeReducer.State)
            case selectWorkSound(SelectNotificationSoundReducer.State)
            case selectBreakSound(SelectNotificationSoundReducer.State)
            case selectActivityGoal(SelectActivityGoalReducer.State)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.selectTimerType, action: /Action.selectTimerType) {
                SelectTimerTypeReducer()
            }
            Scope(state: /State.selectListType, action: /Action.selectListType) {
                SelectListTypeReducer()
            }
            Scope(state: /State.selectWorkSound, action: /Action.selectWorkSound) {
                SelectNotificationSoundReducer()
            }
            Scope(state: /State.selectBreakSound, action: /Action.selectBreakSound) {
                SelectNotificationSoundReducer()
            }
            Scope(state: /State.selectActivityGoal, action: /Action.selectActivityGoal) {
                SelectActivityGoalReducer()
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.services) var services
    @Dependency(\.focusProjectClient) var focusProjectClient
    @Dependency(\.activityGoalClient) var activityGoalClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.userNotifications) var userNotifications

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {

            case .viewDidAppear:
                return monitor()

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

                // MARK: View Actions

            case .dismissButtonPressed:
                return .run { _ in
                    await self.dismiss()
                }

            case .doneButtonPressed:

                return .merge(
                    save(&state),
                    scheduleNotifications(state)
                )

            case .timerTypeRowPressed:
                state.path.append(
                    .selectTimerType(
                        SelectTimerTypeReducer.State(selectedType: state.timerType)
                    )
                )
                return .none

            case .listTypeRowPressed:
                state.path.append(.selectListType(
                    SelectListTypeReducer.State(
                        selectedTimerType: state.timerType,
                        selectedListType: state.project.list
                    )
                ))
                return .none

            case .workSoundRowPressed:
                state.path.append(
                    .selectWorkSound(SelectNotificationSoundReducer.State(sound: state.workSound))
                )
                return .none

            case .breakSoundRowPressed:
                guard state.didPurchasePlus else {
                    state.paywall = .init()
                    return .none
                }
                state.path.append(
                    .selectBreakSound(SelectNotificationSoundReducer.State(sound: state.workSound))
                )
                return .none

            case let .setTitle(title):
                state.project.title = title
                return .none

            case let .setEmoji(emoji):
                state.project.emoji = emoji
                return .none

            case let .selectedThemeColor(color):
                state.project.themeColor = color
                return .none

            case let .setAutostartWorkSession(autostart):
                state.project.timer.autostartWorkSession = autostart
                return .none

            case let .setAutostartBreakSession(autostart):
                state.project.timer.autostartBreakSession = autostart
                return .none

            case let .setWorkLength(length):
                state.workSessionLength = length * 60
                return .none

            case let .setShortBreakLength(length):
                state.shortBreakLength = length * 60
                return .none

            case let .setLongBreakLength(length):
                state.longBreakLength = length * 60
                return .none

            case let .setNumberOfSessions(length):
                state.sessionCount = length

                switch (state.listType, state.timerType) {
                case (.session, .standard):
                    state.project.list = .session(
                        .init(
                            id: uuid(),
                            tasks: state.sessionCount.timesMap { number -> FocusListTask in
                                FocusListTask(
                                    id: uuid(),
                                    title: "Untitled Task \(number + 1)",
                                    completed: false,
                                    inProgress: number == 0,
                                    order: number
                                )
                            }
                        )
                    )
                default:
                    break
                }
                return .none

            case let .setEndRepeat(enabled):
                state.recurrence?.endDate = enabled ? date() : nil
                return .none

            case let .setEndRepeatDate(date):
                guard let date else { return .none }
                state.recurrence?.endDate = Calendar.current.startOfDay(for: date)
                return .none

            case let .setRemindersEnabled(enabled):
                state.recurrence?.reminderDate = enabled ? date() : nil
                return .none

            case let .setReminderTime(date):
                state.recurrence?.reminderDate = date
                return .none

            case .selectActivityGoalButtonPressed:
                if !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }

                state.path.append(
                    .selectActivityGoal(
                        SelectActivityGoalReducer.State(
                            project: state.project
                        )
                    )
                )
                return .none

            case let .removeActivityGoal(goal):
                state.project.activityGoals.removeAll(where: { $0.id == goal.id })
                return .none

            case let .setRepeats(repeats):
                if repeats == true && !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                if repeats {
                    state.recurrence = .init(
                        templateProjectID: state.project.id,
                        repeatingDays: [.sunday]
                    )
                } else {
                    state.recurrence = nil
                }

                return .none

            case let .toggleDayRecurrence(day):
                guard var recurrence = state.recurrence else { return .none }
                if recurrence.repeatingDays.contains(day) {
                    recurrence.repeatingDays.remove(day)
                } else {
                    recurrence.repeatingDays.insert(day)
                }
                state.recurrence = recurrence
                HapticFeedbackGenerator.impactOccurred(.medium)
                return .none

            case let .setSaving(saving):
                state.isSaving = saving
                return .none

                // MARK: Navigation Actions

            case let .path(.element(id: id, action: .selectTimerType(.selectedTimerType(type)))):
                guard type != state.project.timer.type else { return .none }

                if type == .stopwatch && !state.didPurchasePlus {
                    return .none
                }

                switch type {
                case .standard:
                    state.project.timer = .standard(.init())
                case .stopwatch:
                    state.project.timer = .stopwatch(.init())
                    if state.project.list.isSession {
                        state.project.list = .singleTask(.init(id: uuid()))
                    }
                }

                state.path.pop(from: id)
                return .none

            case let .path(.element(id: id, action: .selectListType(.selectedListType(type)))):
                if type.isPlusFeature && !state.didPurchasePlus {
                    return .none
                }

                switch (type, state.timerType) {
                case (.session, .standard):
                    state.project.list = .session(
                        .init(
                            id: uuid(),
                            tasks: state.sessionCount.timesMap { number -> FocusListTask in
                                FocusListTask(
                                    id: uuid(),
                                    title: "Untitled Task \(number + 1)",
                                    completed: false,
                                    inProgress: number == 0,
                                    order: number
                                )
                            }
                        )
                    )
                default:
                    state.project.list = type
                }
                state.path.pop(from: id)
                return .none

            case let .path(.element(id: id, action: .selectWorkSound(.selectedSound(sound)))):
                if sound.isProSound && !state.didPurchasePlus {
                    return .none
                }

                services.audioPlayer.playNotificationSound(sound)
                state.workSound = sound
                if !state.didPurchasePlus {
                    state.breakSound = sound
                }
                state.path.pop(from: id)
                return .none

            case let .path(.element(id: id, action: .selectBreakSound(.selectedSound(sound)))):
                services.audioPlayer.playNotificationSound(sound)
                state.breakSound = sound
                state.path.pop(from: id)
                return .none

            case let .path(.element(id: _, action: .selectActivityGoal(.selectActivityGoal(goal)))):
                if state.project.activityGoals.contains(goal) {
                    state.project.activityGoals.removeAll(where: { $0.id == goal.id })
                } else {
                    state.project.activityGoals.append(goal)
                }
                return .none

            case .path:
                return .none

            case .delegate:
                return .none

            case .paywall:
                return .none
            }
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
        .forEach(\State.path, action: /Action.path) {
            Path()
        }
    }

    func createTimer(
        type: TimerType,
        config: StandardTimerConfiguration,
        workSound: NotificationSound,
        breakSound: NotificationSound
    ) -> FocusTimer {
        switch type {
        case .standard:
            return .standard(
                StandardTimer(
                    id: uuid(),
                    config: config
                )
            )
        case .stopwatch:
            return .stopwatch(StopwatchTimer())
        }
    }

    // swiftlint:disable function_body_length
    func save(_ state: inout State) -> EffectTask<Action> {
        guard state.isEditing else {
            // If I'm creating, then I'm always setting a recurrence template
            state.project.recurrenceTemplate = state.recurrence
            return EffectTask(value: .setSaving(true))
                .concatenate(
                    with: .run { [focusProjectClient, state] send in
                        try await focusProjectClient.createProject(state.project)
                        await send(.delegate(.didCreateProject))
                    }
                )
                .concatenate(with: .run { _ in
                    await self.dismiss()
                })
        }

        let previous = state.oldProject
        var updated = state.project
        let recurrence = state.recurrence
        let updateEffect: EffectTask<Action>

        // We're editing a scheduled project
        if previous.isRecurrenceTemplate {
            // We're creating a one off for today from the template
            if recurrence == nil {
                var updated = updated
                updated.recurrence = nil
                updated.recurrenceTemplate = nil
                updated.scheduledDate = date()
                updateEffect = .run { [updated] _ in
                    try await focusProjectClient.updateProject(updated)
                }
            } else {
                // We're just updating the recurrence and template
                updated.recurrenceTemplate = state.recurrence
                updateEffect = .run { [updated] _ in
                    try await focusProjectClient.updateProject(updated)
                }
            }

        } else { // We're editing a created project
            updated.recurrence = recurrence
            // We're editing a one off project
            if previous.recurrence == nil {
                // Just update the project and don't worry about recurrence
                if updated.recurrence == nil {
                    updateEffect = .run { [updated] _ in
                        try await focusProjectClient.updateProject(updated)
                    }
                } else {
                    // We are creating a recurring project from a one off.
                    var template = updated
                    template.id = uuid()
                    template.recurrence = nil
                    template.recurrenceTemplate = updated.recurrence
                    template.recurrenceTemplate?.templateProjectID = template.id
                    template.isActive = false
                    template.activityGoals = updated.activityGoals
                    updated.recurrence = template.recurrenceTemplate
                    updated.recurrenceTemplate = nil
                    updateEffect = .run { [updated, template] _ in
                        try await focusProjectClient.createProject(template)
                        try await focusProjectClient.updateProject(updated)
                    }
                }
            } else { // We're editing a created project that has a recurrence rule

                // We're cancelling all future recurrences of this project
                if updated.recurrence == nil {
                    updateEffect = .run { [updated] _ in
                        try await focusProjectClient.updateProject(updated)
                        try await focusProjectClient.deleteRecurrence(previous.recurrence!)
                    }
                } else { // We're updating the recurrence and potentially the template
                    updateEffect = .run { [updated] _ in
                        try await focusProjectClient.updateProject(updated)
                    }
                }
            }

        }

        return updateEffect
            .concatenate(with: .run { _ in
                await self.dismiss()
            })
    }

    func monitor() -> EffectTask<Action> {
        userClient.monitorUser()
            .catchToEffect()
            .map { result in
                switch result {
                case let .success(user):
                    return .setDidPurchasePlus(user.didPurchasePlus)
                case .failure:
                    fatalError()
                }
            }
    }

    private func scheduleNotifications(_ state: State) -> EffectTask<Action> {
        let cancelNotificationsEffect: EffectTask<Action> = .run { [state] _ in
            await userNotifications.removePendingNotificationRequestsWithIdentifiers([state.project.id.uuidString])
            for day in WeekDay.allCases {
                await userNotifications.removePendingNotificationRequestsWithIdentifiers([state.project.id.uuidString + "\(day.rawValue)"])
            }
        }

        var scheduleNotificationsEffect: EffectTask<Action> = .none

        if state.remindersEnabled, let reminderTime = state.reminderDate {
            scheduleNotificationsEffect = .run { _ in
                let reminderTimeDateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                var dateComponents = DateComponents()
                dateComponents.month = reminderTimeDateComponents.month
                dateComponents.hour = reminderTimeDateComponents.hour
                dateComponents.minute = reminderTimeDateComponents.minute

                for day in state.repeatingDays {
                    var components = dateComponents
                    components.weekday = day.rawValue + 1
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let content = UNMutableNotificationContent()
                    content.title = "\(state.project.emoji) \(state.project.title) reminder"
                    content.body = "This is a reminder to work on project \(state.project.title)."
                    content.sound = .default
                    let request = UNNotificationRequest(
                        identifier: state.project.id.uuidString + "\(day.rawValue)",
                        content: content,
                        trigger: trigger
                    )
                    try await userNotifications.add(request)
                }
            }

        }

        return cancelNotificationsEffect
            .concatenate(with: scheduleNotificationsEffect)
    }
}

extension CreateFocusProjectReducer.State {

    var workSessionLength: Int {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.workSessionLength
            default:
                return 0
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                var config = timer.config
                config.workSessionLength = newValue
                timer.update(with: config)
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var shortBreakLength: Int {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.shortBreakLength
            default:
                return 0
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                var config = timer.config
                config.shortBreakLength = newValue
                timer.update(with: config)
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var longBreakLength: Int {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.longBreakLength
            default:
                return 0
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                var config = timer.config
                config.longBreakLength = newValue
                timer.update(with: config)
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var sessionCount: Int {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.sessionCount
            default:
                return 0
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                var config = timer.config
                config.sessionCount = newValue
                timer.update(with: config)
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var workSound: NotificationSound {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.workSound
            default:
                return .bell
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                timer.config.workSound = newValue
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var breakSound: NotificationSound {
        get {
            switch project.timer {
            case let .standard(timer):
                return timer.config.breakSound
            default:
                return .bell
            }
        } set {
            switch project.timer {
            case var .standard(timer):
                timer.config.breakSound = newValue
                project.timer = .standard(timer)
            default:
                return
            }
        }
    }

    var timerType: TimerType {
        project.timer.type
    }

    var listType: FocusListType {
        project.list.listType
    }
}
