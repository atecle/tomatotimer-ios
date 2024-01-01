//
//  FocusProjectClientTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 8/20/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import CoreData
import CustomDump

@testable import TomatoTimer

@MainActor
// swiftlint:disable type_body_length file_length
final class FocusProjectClientTests: CoreDataTestCase<NSPersistentContainer> {

    // MARK: - Creation

    func test_create_project() async throws {
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        let project = FocusProject()

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }
    }

    func test_create_project_with_activity_goal() async throws {
        let activityGoalRepository: CoreDataRepository<ActivityGoalEntity> = .live(coreDataStack: CoreDataStack.live)
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: activityGoalRepository
        )

        var project = FocusProject()
        let goal = ActivityGoal()
        project.activityGoals = [goal]

        try await activityGoalRepository.create(goal)
        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
            XCTAssertTrue(results[0].activityGoals?.count == 1)

            let activityGoals = ((results[0].activityGoals ?? .init()).toArray() as [ActivityGoalEntity])
            .compactMap { $0.toNonManagedObject() }

            XCTAssertEqual(activityGoals[0], goal)
        }
    }

    func test_create_project_recurrence() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()
        project.recurrenceTemplate = .init(templateProjectID: project.id, repeatingDays: .init([.sunday]))

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let projectRequest = FocusProjectEntity.fetchRequest()
            let projectResults = try context.fetch(projectRequest)
            XCTAssertTrue(projectResults.count == 1)
            XCTAssertNoDifference(projectResults[0].toNonManagedObject(), project)

            let recurrenceRequest = FocusProjectRecurrenceEntity.fetchRequest()

            let recurrenceResults = try context.fetch(recurrenceRequest)
            XCTAssertTrue(recurrenceResults.count == 1)
            XCTAssertEqual(recurrenceResults[0].toNonManagedObject(), project.recurrenceTemplate)
        }
    }

    // MARK: - Read

    func test_monitor_project_with_id() async throws {
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        let project = FocusProject()
        let publisher = sut.monitorProjectWithID(project.id)

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }

        let projectEmission = try awaitPublisher(publisher.first())

        XCTAssertEqual(projectEmission, project)
    }

    func test_monitor_scheduled_projects_on_date() async throws {
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        let now = Date()
        let publisher = sut.monitorScheduledProjectsOnDate(now)
        let project = FocusProject(scheduledDate: now)

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }

        let firstEmission = try awaitPublisher(publisher.dropFirst().first())
        XCTAssertEqual(firstEmission[0], project)

        let anHourFromNow = now.byAdding(component: .hour, value: 1)!
        let project2 = FocusProject(scheduledDate: anHourFromNow)
        try await sut.createProject(project2)

        let secondEmission = try awaitPublisher(sut.monitorProjectsOnDate(anHourFromNow).first())

        XCTAssertEqual(secondEmission.count, 2)

        let twoDaysFromNow = now.byAdding(component: .day, value: 2)!

        try await sut.createProject(FocusProject(scheduledDate: twoDaysFromNow))

        let thirdEmission = try awaitPublisher(sut.monitorProjectsOnDate(now).first())

        XCTAssertEqual(thirdEmission.count, 2)
    }

    func test_monitor_active_project() async throws {
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        let project = FocusProject(isActive: true)
        let publisher = sut.monitorActiveProject()

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }

        let projectEmission = try awaitPublisher(publisher.first())

        XCTAssertEqual(projectEmission, project)
    }

    // MARK: - Update

    func test_update_project() async throws {
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()

        try await sut.createProject(project)
        project.title = "Renamed"
        project.emoji = "🍅"
        project.themeColorString = UIColor.appSkyBlue.hexString()
        project.timer.autostartWorkSession = false

        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }
    }

    func test_update_project_activity_goals() async throws {
        let activityGoalRepository: CoreDataRepository<ActivityGoalEntity> = .live(coreDataStack: CoreDataStack.live)
        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalClient: activityGoalRepository
        )

        var project = FocusProject()
        let goal1 = ActivityGoal()
        let goal2 = ActivityGoal()
        project.activityGoals = [goal1]

        try await activityGoalRepository.create(goal1)
        try await activityGoalRepository.create(goal2)
        try await sut.createProject(project)

        project.activityGoals = []

        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
            XCTAssertTrue(results[0].activityGoals?.count == 0)
        }

        project.activityGoals = [goal2]

        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
            XCTAssertTrue(results[0].activityGoals?.count == 1)

            let activityGoals = ((results[0].activityGoals ?? .init()).toArray() as [ActivityGoalEntity])
            .compactMap { $0.toNonManagedObject() }

            XCTAssertEqual(activityGoals[0], goal2)
        }
    }

    func test_update_project_edit_recurrence_template() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()
        project.recurrenceTemplate = .init(templateProjectID: project.id, repeatingDays: .init([.sunday]))

        try await sut.createProject(project)

        project.recurrenceTemplate?.repeatingDays.insert(.monday)

        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertNoDifference(results[0].toNonManagedObject(), project)
        }
    }

    func test_update_project_delete_recurrence_template() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()
        project.recurrenceTemplate = .init(templateProjectID: project.id, repeatingDays: .init([.sunday]))

        try await sut.createProject(project)

        project.recurrenceTemplate = nil

        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertNoDifference(results[0].toNonManagedObject(), project)

            let recurrenceRequest = FocusProjectRecurrenceEntity.fetchRequest()

            let recurrenceResults = try context.fetch(recurrenceRequest)
            XCTAssertTrue(recurrenceResults.count == 0)
        }
    }

    func test_update_project_create_recurring_instance_from_one_off() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        // 1. Create one off project
        var project = FocusProject()

        try await sut.createProject(project)

        // 2. Update the project so it repeats
        project.recurrence = .init(repeatingDays: .init([.sunday]))

        // 3. Create a template from the project and give it a new ID
        var template = project
        template.id = UUID()

        // 4. Set the recurrence template and template projectID
        template.recurrence = nil
        template.recurrenceTemplate = project.recurrence
        template.recurrenceTemplate?.templateProjectID = template.id
        template.isActive = false
        template.activityGoals = project.activityGoals

        project.recurrence = template.recurrenceTemplate
        project.recurrenceTemplate = nil

        try await sut.createProject(template)
        try await sut.updateProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 2)

            for result in results {
                if result.id == template.id {
                    XCTAssertEqual(result.toNonManagedObject(), template)
                } else {
                    XCTAssertEqual(result.toNonManagedObject(), project)
                }
            }

            let recurrenceRequest = FocusProjectRecurrenceEntity.fetchRequest()

            let recurrenceResults = try context.fetch(recurrenceRequest)
            XCTAssertTrue(recurrenceResults.count == 1)
            XCTAssertEqual(recurrenceResults[0].toNonManagedObject(), template.recurrenceTemplate)
            XCTAssertTrue(recurrenceResults[0].instances?.count == 1)
        }
    }

    // MARK: - Delete

    func test_delete_project_without_recurrence_template() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()

        try await sut.createProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 1)
            XCTAssertEqual(results[0].toNonManagedObject(), project)
        }
    }

    func test_delete_project_with_recurrence_template() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()
        project.recurrenceTemplate = .init(templateProjectID: project.id, repeatingDays: .init([.sunday]))

        try await sut.createProject(project)
        try await sut.deleteProject(project)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 0)

            let recurrenceRequest = FocusProjectRecurrenceEntity.fetchRequest()

            let recurrenceResults = try context.fetch(recurrenceRequest)
            XCTAssertTrue(recurrenceResults.count == 0)
        }
    }

    func test_delete_recurrence() async throws {
        let recurrenceRepository: CoreDataRepository<FocusProjectRecurrenceEntity> = .live(
            coreDataStack: CoreDataStack.live
        )

        let sut = FocusProjectClient.live(
            focusProjectRepository: .live(
                coreDataStack: CoreDataStack.live
            ),
            activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
            recurrenceClient: recurrenceRepository,
            activityGoalClient: .live(
                coreDataStack: CoreDataStack.live
            )
        )

        var project = FocusProject()
        project.recurrenceTemplate = .init(templateProjectID: project.id, repeatingDays: .init([.sunday]))

        try await sut.createProject(project)

        try await sut.deleteRecurrence(project.recurrenceTemplate!)

        try await CoreDataStack.live.performChanges { context in
            let request = FocusProjectEntity.fetchRequest()
            request.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
            let results = try context.fetch(request)
            XCTAssertTrue(results.count == 0)

            let recurrenceRequest = FocusProjectRecurrenceEntity.fetchRequest()

            let recurrenceResults = try context.fetch(recurrenceRequest)
            XCTAssertTrue(recurrenceResults.count == 0)
        }
    }
}

extension NSSet {

    func toArray<T>() -> [T] {
       return self.compactMap { $0 as? T }
     }
}
