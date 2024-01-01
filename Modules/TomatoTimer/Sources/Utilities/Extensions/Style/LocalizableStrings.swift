import Foundation

// swiftlint:disable force_cast

// All user facing strings in the app and other string constants
extension String {

    // MARK: - TimerVC

    static let skip = NSLocalizedString("skip", comment: "skip")
    static let work = NSLocalizedString("work", comment: "work session")
    static let workSession = NSLocalizedString("Work session", comment: "work session")
    static let shortBreak = NSLocalizedString("Short Break", comment: "short break")
    static let longBreak = NSLocalizedString("Long Break", comment: "long break")
    static let numberOfSessions = NSLocalizedString("number of sessions", comment: "number of sessions")
    static let session = NSLocalizedString(
        "session",
        comment: "title of label indicating the fraction of sessions complete, e.g. 1/4"
    )
    static let restartTimer = NSLocalizedString("restart timer", comment: "restart entire timer")
    static let restartSession = NSLocalizedString("restart session", comment: "restart this session")
    static let complete = NSLocalizedString("complete", comment: "complete this session")
    static let choose = NSLocalizedString("choose", comment: "choose")
    static let elapsed = NSLocalizedString("elapsed", comment: "title of a label indicating total time elapsed")

    // MARK: - TaskVC

    static let task = NSLocalizedString("task", comment: "task")
    static let inputTaskPromptMessage = NSLocalizedString("what are you working on?",
                                                               comment: "what are you working on?")
    static let startATask = NSLocalizedString("start a task",
                                              comment: "start a task")

    // MARK: - PlannerVC

    static let completed = NSLocalizedString("completed", comment: "completed")
    static let addATask = NSLocalizedString("Add a task", comment: "add a task")
    static let editProjectTitle = NSLocalizedString("Edit Project Title", comment: "completed")
    static let switchProject = NSLocalizedString("Switch Project", comment: "completed")
    static let actionSheetPrompt = NSLocalizedString("What do you want to do", comment: "completed")
    static let todoEmptyMessage = NSLocalizedString("create tasks", comment: "")

    // MARK: - ProjectsVC

    static let projects = NSLocalizedString("Projects", comment: "projects")
    static let inProgress = NSLocalizedString("In Progress", comment: "in progress")
    static let makeActive = NSLocalizedString("make active", comment: "in progress")
    static let editTaskTitle = NSLocalizedString("edit task title", comment: "edit task title")

    // MARK: - SettingsVC

    static let time = NSLocalizedString("time", comment: "time")
    static let themeColor = NSLocalizedString("theme color", comment: "color")
    static let writeAReview = NSLocalizedString("review", comment: "write a review")
    static let contact = NSLocalizedString("contact", comment: "contact")
    static let howToUse = NSLocalizedString("how to use", comment: "how to use")
    static let additional = NSLocalizedString("additional", comment: "additional settings")
    static let done = NSLocalizedString("Done", comment: "done")
    static let other = NSLocalizedString("other", comment: "other")
    static let keepDeviceAwake = NSLocalizedString("keep device awake", comment: "other")
    static let autoStartNextSession
        = NSLocalizedString("autostart next session", comment: "autostart work sessions")
    static let autoStartWorkSession
           = NSLocalizedString("autostart work session", comment: "autostart work sessions")
    static let autoStartBreakSession = NSLocalizedString("autostart break session", comment: "autostart work sessions")
    static let useTodoList
           = NSLocalizedString("use to-do list", comment: "use todo list")
    static let zenMode
              = NSLocalizedString("Zen Mode", comment: "zen mode")
    static let zenModeDescription = NSLocalizedString(
        "Remove current task input and To-Do list. Don't worry about tasks — it's just you, your work, and the timer.",
        comment: "zen mode"
    )
    static let todoList = NSLocalizedString("Use a To-Do List", comment: "todo list")
    static let todoListDescription = NSLocalizedString(
        "Plan ahead with a To-Do list. Switch between To-Do lists with Projects. You can add up to 10 projects and add 15 to-dos per project.",
        comment: "plan ahead with a to do list"
    )

    static let goPro = NSLocalizedString("go pro", comment: "go pro")
    static let upgradeToPremium = NSLocalizedString("unlock more features", comment: "unlock more features")
    static let myEmail = "adam@adamtecle.com"
    static let notifications = NSLocalizedString("notifications", comment: "notifications")

    private static let myName = "Adam"
    static let madeWithLove = NSLocalizedString("Made with ❤️", comment: "made with love")
    static let builtInARage = NSLocalizedString("Built in a rage", comment: "built in a rage")
    static let stopProcrastinating = NSLocalizedString("Stop procrastinating lol", comment: "stop procrastinating")
    static let noReally = NSLocalizedString(
        "No really lol do your work dude",
        comment: "no really lol do your work dude"
    )
    static let whyEasterEgg = NSLocalizedString("It's a little funny that this distracting easter egg exists in a productivity app.", comment: "")
    static let whyEasterEgg2 = NSLocalizedString("Lol", comment: "")
    static let whyEasterEgg3 = NSLocalizedString("Hahahahah", comment: "")
    static let whyEasterEgg4 = NSLocalizedString("Ha", comment: "")
    static let whyEasterEgg4_5 = NSLocalizedString("Hahahahahahhah", comment: "")
    static let whyEasterEgg5 = NSLocalizedString("Nah it's not that funny.", comment: "")
    static let whileYoureHere = NSLocalizedString("While you're here", comment: "ok well while you're here")
    static let mayIAsk = NSLocalizedString("may I ask", comment: "may I ask")
    static let thatYou = NSLocalizedString("that you", comment: "that you")
    static let andIMeanYou = NSLocalizedString("and I mean you...", comment: "and I mean you...")
    static let rateTomatoTimer = NSLocalizedString(
        "Consider rating Tomato Timer on the App Store 💩❤️ 🙏",
        comment: "rate tomato timer"
    )
    static let haveANiceDay = NSLocalizedString("Have a nice day 🍅", comment: "have a nice day 🍅")
    static let footerTextStrings: [String] = [
        footerText(madeWithLove),
        footerText(builtInARage),
        "Do your work",
        "Then take a break",
        whileYoureHere,
        mayIAsk,
        thatYou,
        andIMeanYou,
        rateTomatoTimer,
        haveANiceDay
    ]

    static let footerText: (String) -> String = { (thing) in
        return NSLocalizedString("\(thing)", comment: "footer text")
    }

    static let version = NSLocalizedString("version", comment: "app version")
    static let appVersion: String =
        version + " " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)

    static let sendEmailSubject = NSLocalizedString("", comment: "")

    // MARK: - OnboardingVC

    /// Intro
    static let introOnboardingTitle = NSLocalizedString("what is tomato timer?", comment: "app title")

    static let introOnboardingDescription = NSLocalizedString(
        "tomato timer makes it really easy to stay focused and get stuff done.",
        comment: "app description"
    )

    /// Work Session
    static let workSessionOnboardingTitle = NSLocalizedString("how does it work?", comment: "how does it work")

    static let workSessionOnboardingDescription = NSLocalizedString(
        "first, commit to a single task. then, start the timer and work until it rings.",
        comment: "description of how it works"
    )

    /// Short Break
    static let shortBreakOnboardingTitle = NSLocalizedString("take a short break", comment: "take a break")

    static let shortBreakOnboardingDescription = NSLocalizedString(
        """
         after it rings, relax for a while.\nthis time is for you to do anything you want.
        """,
        comment: "description of how it works")

    /// Long Break
    static let longBreakOnboardingTitle = NSLocalizedString("repeat this cycle", comment: "repeat this cycle")

    static let longBreakOnboardingDescription = NSLocalizedString(
        """
        take a longer break after 4 work sessions. then repeat the cycle all over again.
        """,
        comment: "repeat this cycle description")

    /// Benefits
    static let benefitsOnboardingTitle = NSLocalizedString("what are the benefits?", comment: "why?")

    static let benefitsOnboardingDescription = NSLocalizedString(
        """
you'll find yourself working more efficiently and getting distracted less often.
""",
        comment: "repeat this cycle description")

    static let letsGo = NSLocalizedString("let's go!", comment: "let's go!")

    // MARK: UpgradeVC

    static let upgradeTitle = NSLocalizedString("Tomato Timer Pro", comment: "")
    static let themeColors = NSLocalizedString("More Theme Colors", comment: "")
    static let themeColorsDescription = NSLocalizedString("Use a color picker to set any theme color you want.", comment: "")
    static let restorePurchase = NSLocalizedString("Restore Purchase", comment: "")
    static let moreSoundSettings = NSLocalizedString("Enhanced Notifications", comment: "")
    static let moreSoundSettingsDescription = NSLocalizedString(
"""
Access to 10 more high quality notification sounds.
Choose a different sound for the work and break session.
Choose to autostart either the work session or the break.
""",
        comment: ""
    )
    static let supportDevelopment = NSLocalizedString("Support Development", comment: "Support Continued Development")
    static let supportDevelopmentDescription = NSLocalizedString(
        "Tomato Timer is built by one indie creator in their free time! Tomato Timer's future depends on your support!",
        comment: "Support Continued Development"
    )

    /// App Store

    static let appID = "1453228755"
    static let appStorePageURL = "itms-apps://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page

    // MARK: - Push Notifications

    static let allowNotificationsModalHeader = NSLocalizedString("hi there 👋", comment: "allow notifications modal header")
    static let allowNotificationsModalBody = NSLocalizedString(
        "allow notifications in order for sounds to work!",
        comment: "allow notifications modal body"
    )
    static let allowNotificationsActionButtonTitle = NSLocalizedString(
        "okay",
        comment: "allow notifications modal action button title"
    )

    static let notificationTitle: (SessionType, SessionType) -> (String) = { (ended: SessionType, next: SessionType) in
        return NSLocalizedString(
"""
⏰ \(ended.description.capitalizingFirstLetter) ended. \(next.description.capitalizingFirstLetter) starting.
""",
            comment: "")
    }

    static let notificationBody: (
        SessionType,
        SessionType,
        TomatoTimerConfiguration
    ) -> (String) = { (ended: SessionType, next: SessionType, config: TomatoTimerConfiguration) in
        switch (ended, next) {
        case (.work, .shortBreak):
            return "\(randomCongratulatoryPhrase()) Now, take a \(config.totalSecondsInShortBreakSession / 60) minute break."
        case (.work, .longBreak):
            return "\(randomCongratulatoryPhrase()) Get ready to take a \(config.totalSecondsInLongBreakSession / 60) minute break."
        default:
            let time = config.totalSecondsInWorkSession / 60
            let minuteString = time == 1 ? "minute" : "minutes"
            return "\(randomGettingBackToWorkPhrase()) Get ready to work for \(time) \(minuteString)."
        }
    }

    static let notificationBodyV2: (
        SessionType,
        SessionType,
        StandardTimerConfiguration
    ) -> (String) = { (ended: SessionType, next: SessionType, config: StandardTimerConfiguration) in
        switch (ended, next) {
        case (.work, .shortBreak):
            return "\(randomCongratulatoryPhrase()) Now, take a \(config.shortBreakLength / 60) minute break."
        case (.work, .longBreak):
            return "\(randomCongratulatoryPhrase()) Get ready to take a \(config.longBreakLength / 60) minute break."
        default:
            let time = config.workSessionLength / 60
            let minuteString = time == 1 ? "minute" : "minutes"
            return "\(randomGettingBackToWorkPhrase()) Get ready to work for \(time) \(minuteString)."
        }
    }

    static let pomodoroFinishedNotificationTitle = NSLocalizedString("All sessions complete!", comment: "")
    static let pomodoroFinishedNotificationBody = NSLocalizedString(
        "Woohoo! Great work! You finished all your work sessions! Tap the timer to start again.",
        comment: ""
    )

    static let randomCongratulatoryPhrase: () -> String = {
        return congratulatoryPhrases.randomElement()!
    }

    static let randomGettingBackToWorkPhrase: () -> String = {
        return gettingBackToWorkPhrase.randomElement()!
    }

    static let congratulatoryPhrases: [String] = [
        "👏 Awesome work!",
        "Nice job!",
        "💪 You're killing it!",
        "Great work!",
        "Great job!",
        "Excellent work!",
        "Fantastic job!",
        "Nice.",
        "🎉 You're getting better!",
        "🙌 Keep up the good work!",
        "Way to go!",
        "A fine job.",
        "Tremendous."
    ]

    static let gettingBackToWorkPhrase: [String] = [
        "Time to buckle down!",
        "OK! Let's get focused!",
        "You ready?",
        "Let's get back at it!"
    ]

    // MARK: - Alerts

    static let ok = NSLocalizedString("OK", comment: "OK")
    static let save = NSLocalizedString("save", comment: "save")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let addTask = NSLocalizedString("add a task", comment: "add a task")
    static let viewProjects = NSLocalizedString("view projects", comment: "add a task")
    static let project = NSLocalizedString("Project", comment: "project")
    static let chooseAction = NSLocalizedString("choose action", comment: "choose action")
    static let startTask = NSLocalizedString("start task", comment: "Start Task")
    static let markComplete = NSLocalizedString("mark complete", comment: "Mark Complete")
    static let editTitle = NSLocalizedString("edit title", comment: "Edit Title")
    static let delete = NSLocalizedString("Delete", comment: "Delete")
    static let addProject = NSLocalizedString("Enter a name for this project", comment: "add project")
    static let confirm = NSLocalizedString("confirm", comment: "Confirm")
    static let completeThisTask = NSLocalizedString("Mark task complete?", comment: "Mark task complete?")

}
