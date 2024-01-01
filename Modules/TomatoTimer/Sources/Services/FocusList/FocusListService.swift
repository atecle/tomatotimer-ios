//
//  FocusListService.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine
import CoreData

protocol FocusListServiceProvider {
    var focusListService: FocusListServiceType { get }
}

protocol FocusListServiceType {
    func monitor(_ list: FocusList) -> AnyPublisher<FocusList, Error>
    func update(_ list: FocusList) async throws
}

struct FocusListService: FocusListServiceType {

    private let standardListRepository: Repository<StandardListEntity>
    private let sessionListRepository: Repository<SessionListEntity>
    private let singleTaskListRepository: Repository<SingleTaskListEntity>

    init(
        standardListRepository: Repository<StandardListEntity>,
        sessionListRepository: Repository<SessionListEntity>,
        singleTaskListRepository: Repository<SingleTaskListEntity>
    ) {
        self.standardListRepository = standardListRepository
        self.sessionListRepository = sessionListRepository
        self.singleTaskListRepository = singleTaskListRepository
    }

    func monitor(_ list: FocusList) -> AnyPublisher<FocusList, Error> {
        switch list {
        case let .standard(list):
            let request: NSFetchRequest<StandardListEntity> = StandardListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = StandardListEntity.defaultSortDescriptors
            return standardListRepository.monitor(request)
                .compactMap(\.first)
                .map { .standard($0) }
                .eraseToAnyPublisher()
        case let .session(list):
            let request: NSFetchRequest<SessionListEntity> = SessionListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = SessionListEntity.defaultSortDescriptors
            return sessionListRepository.monitor(request)
                .compactMap(\.first)
                .map { .session($0) }
                .eraseToAnyPublisher()
        case let .singleTask(list):
            let request: NSFetchRequest<SingleTaskListEntity> = SingleTaskListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = SingleTaskListEntity.defaultSortDescriptors
            return singleTaskListRepository.monitor(request)
                .compactMap(\.first)
                .map { .singleTask($0) }
                .eraseToAnyPublisher()
        case .none:
            return Just(.none).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }

    func update(_ list: FocusList) async throws {
        switch list {
        case let .standard(list):
            let request: NSFetchRequest<StandardListEntity> = StandardListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = StandardListEntity.defaultSortDescriptors
            try await standardListRepository.update(fetchRequest: request, nonManaged: list)
        case let .session(list):
            let request: NSFetchRequest<SessionListEntity> = SessionListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = SessionListEntity.defaultSortDescriptors
            try await sessionListRepository.update(fetchRequest: request, nonManaged: list)
        case let .singleTask(list):
            let request: NSFetchRequest<SingleTaskListEntity> = SingleTaskListEntity.fetchRequest()
            request.predicate = .byID(list.id)
            request.sortDescriptors = SingleTaskListEntity.defaultSortDescriptors
            try await singleTaskListRepository.update(fetchRequest: request, nonManaged: list)
        case .none:
            return
        }

    }
}

extension NSPredicate {
    static var byID: (UUID) -> NSPredicate {
        return { id in
            .init(format: "%K == %@", "id", id as CVarArg)
        }
    }
}
