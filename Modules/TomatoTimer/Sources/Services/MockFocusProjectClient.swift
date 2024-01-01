//
//  MockFocusProjectClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/21/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine

// swiftlint:disable all
struct MockFocusProjectClient: FocusProjectClientType {
    var createProject: (FocusProject) async throws -> Void

    var monitorProjectWithID: (UUID) -> AnyPublisher<FocusProject, Error>

    var monitorProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error>

    var monitorActiveProject: () -> AnyPublisher<FocusProject, Error>

    var monitorScheduledProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error>

    var monitorActivityTotals: () -> AnyPublisher<ActivityTotals, Error>

    var monitorWeeklyActivityTotals: (Date) -> AnyPublisher<WeeklyActivityTotals, Error>

    var monitorProjectsInWeek: (Week) -> AnyPublisher<[FocusProject], Error>

    var update: (UUID, @escaping (inout FocusProject) -> Void) async throws -> Void

    var updateProject: (FocusProject) async throws -> Void

    var updateActiveProject: (@escaping (inout FocusProject) -> Void) async throws -> Void

    var updateAllProjectsInactive: () async throws -> Void

    var deleteProject: (FocusProject) async throws -> Void

    var deleteRecurrence: (FocusProject.Recurrence) async throws -> Void

    var deleteAllRecurringProjectInstances: (FocusProject.Recurrence) async throws -> Void

    static func live(
    ) -> Self {
        Self(
            createProject: { project in

            },
            monitorProjectWithID: { id in
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorProjectsOnDate: { date in
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorActiveProject: {
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorScheduledProjectsOnDate: { date in
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorActivityTotals: {
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorWeeklyActivityTotals: { day in
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            monitorProjectsInWeek: { week in
                Just(.init()).setFailureType(to: Error.self).eraseToAnyPublisher()
            },
            update: { id, updateProject in

            },
            updateProject: { project in

            },
            updateActiveProject: { updateProject in

            },
            updateAllProjectsInactive: {

            },
            deleteProject: { project in

            },
            deleteRecurrence: { recurrence in

            },
            deleteAllRecurringProjectInstances: { recurrence in

            }
        )
    }
}
