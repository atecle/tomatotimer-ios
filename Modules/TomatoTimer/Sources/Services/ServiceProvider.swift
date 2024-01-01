import Foundation
import Dependencies

typealias ServiceProvider = TimerServiceProvider
    & SettingsServiceProvider
    & ProjectServiceProvider
    & TimerNotificationServiceProvider
    & UserDefaultsServiceProvider
    & AudioPlayerServiceProvider
    & FocusProjectServiceProvider
    & FocusListServiceProvider

struct Services: ServiceProvider {

    private let coreDataStack: CoreDataStackType
    let timerService: TimerServiceType
    let settingsService: SettingsServiceType
    let projectService: ProjectServiceType
    let focusProjectService: FocusProjectServiceType
    let focusListService: FocusListServiceType
    let timerNotificationService: TimerNotificationServiceType
    let userDefaultsService: UserDefaultsServiceType
    var audioPlayer: AudioPlayerServiceType

    init(
        coreDataStack: CoreDataStackType
    ) {
        self.coreDataStack = coreDataStack
        self.timerService = TimerService(
            repository: Repository<TomatoTimerEntity>(coreDataStack: coreDataStack),
            standardTimerRepository: Repository<StandardTimerEntity>(coreDataStack: coreDataStack),
            stopwatchTimerRepository: Repository<StopwatchTimerEntity>(coreDataStack: coreDataStack)
        )
        self.settingsService = SettingsService(
            repository: Repository<SettingsEntity>(coreDataStack: coreDataStack)
        )
        self.projectService = ProjectService(
            repository: Repository<ToDoListProjectEntity>(coreDataStack: coreDataStack)
        )
        self.focusProjectService = FocusProjectService(
            repository: Repository<FocusProjectEntity>(coreDataStack: coreDataStack)
        )
        self.focusListService = FocusListService(
            standardListRepository: .init(coreDataStack: coreDataStack),
            sessionListRepository: .init(coreDataStack: coreDataStack),
            singleTaskListRepository: .init(coreDataStack: coreDataStack)
        )
        self.userDefaultsService = UserDefaultsService()
        self.timerNotificationService = TimerNotificationService()
        self.audioPlayer = AudioPlayerService()
    }
}
