//
//  FocusProjectService.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine

protocol FocusProjectServiceProvider {
    var focusProjectService: FocusProjectServiceType { get }
}

protocol FocusProjectServiceType {
    func monitor(_ focusProject: FocusProject) -> AnyPublisher<FocusProject, Error>
    func monitor(for date: Date) -> AnyPublisher<[FocusProject], Error>
    func create(_ project: FocusProject) async throws
    func update(_ project: FocusProject) async throws
    func delete(_ project: FocusProject) async throws
}

struct FocusProjectService: FocusProjectServiceType {

    private let repository: Repository<FocusProjectEntity>

    init(
        repository: Repository<FocusProjectEntity>
    ) {
        self.repository = repository
    }

    func monitor(_ project: FocusProject) -> AnyPublisher<FocusProject, Error> {
        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", project.id as CVarArg)
        return repository.monitor(request)
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func monitor(for date: Date) -> AnyPublisher<[FocusProject], Error> {
        let request = FocusProjectEntity.fetchRequest()
        request.predicate = NSPredicate.scheduledDatePredicate(for: date)
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        return repository.monitor(request)
    }

    func create(_ project: FocusProject) async throws {
        try await repository.create(project)
    }

    func update(_ project: FocusProject) async throws {
        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", project.id as CVarArg)
        try await repository.update(fetchRequest: request, nonManaged: project)
    }

    func delete(_ project: FocusProject) async throws {
        let request = FocusProjectEntity.fetchRequest()
        request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", project.id as CVarArg)
        try await repository.delete(fetchRequest: request, nonManaged: project)
    }
}
