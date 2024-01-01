//
//  StandardTimerClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData
import Combine
import Dependencies

struct StandardTimerClient {

    var monitorWithID: (UUID) -> AnyPublisher<StandardTimer, Error>

    static func live(
        coreDataClient: CoreDataRepository<StandardTimerEntity>
    ) -> Self {
        return Self(
            monitorWithID: { id in
                let request: NSFetchRequest<StandardTimerEntity> = StandardTimerEntity.fetchRequest()
                request.predicate = .byID(id)
                request.sortDescriptors = StandardTimerEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            }
        )
    }
}

extension StandardTimerClient: DependencyKey {
    static let liveValue: StandardTimerClient = StandardTimerClient.live(
        coreDataClient: .live(
            coreDataStack: CoreDataStack.live
        )
    )
}
