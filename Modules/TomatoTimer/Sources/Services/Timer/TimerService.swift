import Foundation
import Combine
import CoreData

protocol TimerServiceProvider {
    var timerService: TimerServiceType { get }
}

protocol TimerServiceType {
    func fetchAll() async throws -> [TomatoTimer]
    func monitor() -> AnyPublisher<[TomatoTimer], Error>
    func add(_ timer: TomatoTimer) async throws
    func timer() -> AnyPublisher<TomatoTimer, Error>
    func update(_ timer: TomatoTimer) async throws

    func monitor(_ timer: FocusTimer) -> AnyPublisher<FocusTimer, Error>
    func update(_ timer: FocusTimer) async throws
}

struct TimerService: TimerServiceType {

    // MARK: - Properties

    // MARK: Data Store

    private let repository: Repository<TomatoTimerEntity>
    private let standardTimerRepository: Repository<StandardTimerEntity>
    private let stopwatchTimerRepository: Repository<StopwatchTimerEntity>

    // MARK: - Methods

    // MARK: Initialization

    init(
        repository: Repository<TomatoTimerEntity>,
        standardTimerRepository: Repository<StandardTimerEntity>,
        stopwatchTimerRepository: Repository<StopwatchTimerEntity>
    ) {
        self.repository = repository
        self.standardTimerRepository = standardTimerRepository
        self.stopwatchTimerRepository = stopwatchTimerRepository
    }

    // MARK: TimerServiceType

    // Old

    func fetchAll() async throws -> [TomatoTimer] {
        let request = TomatoTimerEntity.fetchRequest()
        request.sortDescriptors = TomatoTimerEntity.defaultSortDescriptors
        return try await repository.fetchAll(request)
    }

    func monitor() -> AnyPublisher<[TomatoTimer], Error> {
        let request = TomatoTimerEntity.fetchRequest()
        request.sortDescriptors = TomatoTimerEntity.defaultSortDescriptors
        return repository.monitor(request)
            .eraseToAnyPublisher()
    }

    func add(_ timer: TomatoTimer) async throws {
        try await repository.create(timer)
    }

    func timer() -> AnyPublisher<TomatoTimer, Error> {
        let request = TomatoTimerEntity.fetchRequest()
        request.sortDescriptors = TomatoTimerEntity.defaultSortDescriptors
        return repository.monitor(request)
            .compactMap { $0.first }
            .eraseToAnyPublisher()
    }

    func update(_ timer: TomatoTimer) async throws {
        let request = TomatoTimerEntity.fetchRequest()
        request.sortDescriptors = TomatoTimerEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", timer.id as CVarArg)
        try await repository.update(fetchRequest: request, nonManaged: timer)
    }

    // New

    func monitor(_ timer: FocusTimer) -> AnyPublisher<FocusTimer, Error> {
        switch timer {
        case let .standard(timer):
            return monitor(timer).map { .standard($0 ) }.eraseToAnyPublisher()
        case let .stopwatch(timer):
            return monitor(timer).map { .stopwatch($0 ) }.eraseToAnyPublisher()
        }
    }

    func monitor(_ timer: StandardTimer) -> AnyPublisher<StandardTimer, Error> {
        let request: NSFetchRequest<StandardTimerEntity> = StandardTimerEntity.fetchRequest()
        request.predicate = .init(format: "%K == %@", "id", timer.id as CVarArg)
        request.sortDescriptors = StandardTimerEntity.defaultSortDescriptors
        return standardTimerRepository.monitor(request)
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func monitor(_ timer: StopwatchTimer) -> AnyPublisher<StopwatchTimer, Error> {
        let request: NSFetchRequest<StopwatchTimerEntity> = StopwatchTimerEntity.fetchRequest()
        request.predicate = .init(format: "%K == %@", "id", timer.id as CVarArg)
        request.sortDescriptors = StopwatchTimerEntity.defaultSortDescriptors
        return stopwatchTimerRepository.monitor(request)
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func update(_ timer: FocusTimer) async throws {
        switch timer {
        case let .standard(timer):
            try await update(timer)
        case let .stopwatch(timer):
            try await update(timer)
        }
   }

     func update(_ timer: StandardTimer) async throws {
        let request: NSFetchRequest<StandardTimerEntity> = StandardTimerEntity.fetchRequest()
        request.predicate = .init(format: "%K == %@", "id", timer.id as CVarArg)
        request.sortDescriptors = StandardTimerEntity.defaultSortDescriptors
        try await standardTimerRepository.update(fetchRequest: request, nonManaged: timer)
    }

    func update(_ timer: StopwatchTimer) async throws {
       let request: NSFetchRequest<StopwatchTimerEntity> = StopwatchTimerEntity.fetchRequest()
       request.predicate = .init(format: "%K == %@", "id", timer.id as CVarArg)
       request.sortDescriptors = StopwatchTimerEntity.defaultSortDescriptors
       try await stopwatchTimerRepository.update(fetchRequest: request, nonManaged: timer)
   }

}

//
//Calendar.current.date(byAdding: .day, value: -3, to: TimerService.today)!: [
//    .standardTimerStandardListPreview
//],
//Calendar.current.date(byAdding: .day, value: -2, to: TimerService.today)!: [
//
//],
//Calendar.current.date(byAdding: .day, value: -1, to: TimerService.today)!: [
//
//],
//Calendar.current.date(byAdding: .day, value: 0, to: TimerService.today)!: [
//    .standardTimerStandardListPreview,
//    .standardTimerSessionListPreview,
//    .freestyleTimerNoListPreview
//],
//Calendar.current.date(byAdding: .day, value: 1, to: TimerService.today)!: [
//    .standardTimerSingleTaskPreview
//],
//Calendar.current.date(byAdding: .day, value: 2, to: TimerService.today)!: [
//
//],
//Calendar.current.date(byAdding: .day, value: 3, to: TimerService.today)!: [
//
//]
