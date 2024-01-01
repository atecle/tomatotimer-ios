import Foundation
import Combine

protocol SettingsServiceProvider {
    var settingsService: SettingsServiceType { get }
}

protocol SettingsServiceType {
    func fetchAll() async throws -> [Settings]
    func monitor() -> AnyPublisher<[Settings], Error>
    func add(_ settings: Settings) async throws
    func settings() -> AnyPublisher<Settings, Error>
    func update(_ settings: Settings) async throws
}

struct SettingsService: SettingsServiceType {

    private let repository: Repository<SettingsEntity>

    init(
        repository: Repository<SettingsEntity>
    ) {
        self.repository = repository
    }

    func fetchAll() async throws -> [Settings] {
        let request = SettingsEntity.fetchRequest()
        request.sortDescriptors = SettingsEntity.defaultSortDescriptors
        return try await repository.fetchAll(request)
    }

    func monitor() -> AnyPublisher<[Settings], Error> {
        let request = SettingsEntity.fetchRequest()
        request.sortDescriptors = SettingsEntity.defaultSortDescriptors
        return repository.monitor(request)
            .eraseToAnyPublisher()
    }

    func add(_ settings: Settings) async throws {
        try await repository.create(settings)
    }

    func settings() -> AnyPublisher<Settings, Error> {
        let request = SettingsEntity.fetchRequest()
        request.sortDescriptors = SettingsEntity.defaultSortDescriptors
        return repository.monitor(request)
            .compactMap { $0.first }
            .eraseToAnyPublisher()
    }

    func update(_ settings: Settings) async throws {
        let request = SettingsEntity.fetchRequest()
        request.sortDescriptors = SettingsEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", settings.id as CVarArg)
        try await repository.update(fetchRequest: request, nonManaged: settings)
    }
}
