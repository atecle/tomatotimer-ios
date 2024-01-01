//
//  StopwatchTimerClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine
import CoreData
import Dependencies

struct StopwatchTimerClient {

    var monitorWithID: (UUID) -> AnyPublisher<StopwatchTimer, Error>

    static func live(
        coreDataClient: CoreDataRepository<StopwatchTimerEntity>
    ) -> Self {
        return Self(
            monitorWithID: { id in
                let request: NSFetchRequest<StopwatchTimerEntity> = StopwatchTimerEntity.fetchRequest()
                request.predicate = .byID(id)
                request.sortDescriptors = StopwatchTimerEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            }
        )
    }
}

extension StopwatchTimerClient: DependencyKey {
    static let liveValue: StopwatchTimerClient = StopwatchTimerClient.live(
        coreDataClient: .live(
            coreDataStack: CoreDataStack.live
        )
    )
}
