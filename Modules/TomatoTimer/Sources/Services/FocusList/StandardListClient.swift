//
//  StandardListClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine
import CoreData
import Dependencies

struct StandardListClient {

    var moveTaskFromOffsetsToOffset: (UUID, (IndexSet, Int)) async throws -> Void
    var monitorListWithID: (UUID) -> AnyPublisher<StandardList, Error>

    static func live(
        coreDataClient: CoreDataRepository<StandardListEntity>
    ) -> Self {
        Self(
            moveTaskFromOffsetsToOffset: { id, move in
                let request: NSFetchRequest<StandardListEntity> = StandardListEntity.fetchByID(id: id)
                try await coreDataClient.updateOne(request) { listEntity, context in
                    guard var list = listEntity?.toNonManagedObject() else { return }
                    list.tasks.move(fromOffsets: move.0, toOffset: move.1)
                    listEntity?.update(from: list, context: context)
                }
            },
            monitorListWithID: { id in
                let request: NSFetchRequest<StandardListEntity> = StandardListEntity.fetchRequest()
                request.predicate = .byID(id)
                request.sortDescriptors = StandardListEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            }
        )
    }
}

extension StandardListClient: DependencyKey {
    static let liveValue: StandardListClient = StandardListClient.live(
        coreDataClient: .live(
            coreDataStack: CoreDataStack.live
        )
    )
}
