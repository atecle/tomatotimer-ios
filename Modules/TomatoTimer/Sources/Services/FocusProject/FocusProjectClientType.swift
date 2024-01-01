import Foundation
import Combine

protocol FocusProjectClientType {

    // MARK: - Create

    var createProject: (FocusProject) async throws -> Void { get }

    // MARK: - Read

    // Monitoring

    var monitorProjectWithID: (UUID) -> AnyPublisher<FocusProject, Error> { get }

    // Focus Tab
    var monitorProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error> { get }
    var monitorActiveProject: () -> AnyPublisher<FocusProject, Error> { get }
    var monitorScheduledProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error> { get }

    // Activity Tab
    var monitorActivityTotals: () -> AnyPublisher<ActivityTotals, Error> { get }
    var monitorWeeklyActivityTotals: (Date) -> AnyPublisher<WeeklyActivityTotals, Error> { get }
    var monitorProjectsInWeek: (Week) -> AnyPublisher<[FocusProject], Error> { get }

    // MARK: Update

    var update: (UUID, @escaping (inout FocusProject) -> Void) async throws -> Void { get }
    var updateProject: (FocusProject) async throws -> Void { get }
    var updateActiveProject: (@escaping (inout FocusProject) -> Void) async throws -> Void { get }
    var updateAllProjectsInactive: () async throws -> Void { get }

    // MARK: Delete

    var deleteProject: (FocusProject) async throws -> Void { get }
    var deleteRecurrence: (FocusProject.Recurrence) async throws -> Void { get }
    var deleteAllRecurringProjectInstances: (FocusProject.Recurrence) async throws -> Void { get }
}
