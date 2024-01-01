//
//  FocusProjectClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData
import Combine
import CustomDump
import Dependencies

struct FocusProjectClient: FocusProjectClientType {

    // MARK: - Create

    var createProject: (FocusProject) async throws -> Void

    // MARK: - Read

    // Monitoring

    var monitorProjectWithID: (UUID) -> AnyPublisher<FocusProject, Error>

    // Focus Tab
    var monitorProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error>
    var monitorActiveProject: () -> AnyPublisher<FocusProject, Error>
    var monitorScheduledProjectsOnDate: (Date) -> AnyPublisher<[FocusProject], Error>

    // Activity Tab
    var monitorActivityTotals: () -> AnyPublisher<ActivityTotals, Error>
    var monitorWeeklyActivityTotals: (Date) -> AnyPublisher<WeeklyActivityTotals, Error>
    var monitorProjectsInWeek: (Week) -> AnyPublisher<[FocusProject], Error>

    // MARK: Update

    var update: (UUID, @escaping (inout FocusProject) -> Void) async throws -> Void
    var updateProject: (FocusProject) async throws -> Void
    var updateActiveProject: (@escaping (inout FocusProject) -> Void) async throws -> Void
    var updateAllProjectsInactive: () async throws -> Void

    // MARK: Delete

    var deleteProject: (FocusProject) async throws -> Void
    var deleteRecurrence: (FocusProject.Recurrence) async throws -> Void
    var deleteAllRecurringProjectInstances: (FocusProject.Recurrence) async throws -> Void

    // MARK: - Methods

    // swiftlint:disable:next function_body_length
    static func live(
        focusProjectRepository: CoreDataRepository<FocusProjectEntity>,
        activityGoalRelationshipRepository: CoreDataRelationshipRepository<ActivityGoalEntity, FocusProjectEntity>,
        recurrenceRelationshipRepository: CoreDataRelationshipRepository<FocusProjectRecurrenceEntity, FocusProjectEntity>,
        recurrenceClient: CoreDataRepository<FocusProjectRecurrenceEntity>,
        activityGoalClient: CoreDataRepository<ActivityGoalEntity>
    ) -> Self {
        Self(
            createProject: { project in

                // 1. Create Project
                try await focusProjectRepository.create(project)
                let updateRequest: NSFetchRequest<ActivityGoalEntity> = ActivityGoalEntity.fetchByIDs(ids: project.activityGoals.map(\.id))
                let fetchRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(id: project.id)

                // 2. Deal with recurrence
                // Creating a new project with recurrence and not a recurrenceTemplate
                // only happens when tapping on a scheduled project, where we create a project
                // from the template
                if let recurrence = project.recurrence {
                    let recurrenceRequest: NSFetchRequest<FocusProjectRecurrenceEntity> = FocusProjectRecurrenceEntity.fetchByID(
                        id: recurrence.id
                    )

                    try await recurrenceRelationshipRepository.updateRelationship(
                        recurrenceRequest,
                        fetchRequest
                    ) { recurrenceEntities, projectEntities in
                        guard let projectEntity = projectEntities.first else { return }
                        guard let recurrenceEntity = recurrenceEntities.first else { return }

                        recurrenceEntity.addToInstances(projectEntity)
                    }
                }

                // 3. Associate with activity goals
                try await activityGoalRelationshipRepository.updateRelationship(
                    updateRequest,
                    fetchRequest
                ) { activityGoalEntities, projectEntities in
                    guard let projectEntity = projectEntities.first else { return }

                    for activityGoalEntity in activityGoalEntities {
                        activityGoalEntity.addToProjects(projectEntity)
                    }
                }
            },
            monitorProjectWithID: { id in
                let projectsRequest = FocusProjectEntity.fetchRequest()
                projectsRequest.predicate = .byID(id)
                return focusProjectRepository.monitor(projectsRequest)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            },
            monitorProjectsOnDate: { date in
                let projectsRequest = FocusProjectEntity.fetchRequest()
                let datePredicate = NSPredicate.scheduledDatePredicate(for: date)
                let isNotTemplate = NSPredicate(format: "recurrenceTemplate = nil")
                projectsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, isNotTemplate])
                projectsRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FocusProjectEntity.creationDate), ascending: true)]
                return focusProjectRepository.monitor(projectsRequest)
                    .eraseToAnyPublisher()
            },
            monitorActiveProject: {
                let request = FocusProjectEntity.fetchRequest()
                request.predicate = .init(format: "isActive == %@", NSNumber(value: true))
                return focusProjectRepository.monitor(request)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            },
            monitorScheduledProjectsOnDate: { date in

                // 1. First we assemble a request for created projects.
                let projectsRequest = FocusProjectEntity.fetchRequest()
                let datePredicate = NSPredicate.scheduledDatePredicate(for: date)
                let isNotTemplate = NSPredicate(format: "recurrenceTemplate = nil")
                projectsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, isNotTemplate])
                projectsRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FocusProjectEntity.creationDate), ascending: true)]
                let createdProjects = focusProjectRepository.monitor(projectsRequest)
                    .eraseToAnyPublisher()

                // 2. If the date is in the past, we only show created projects
                guard Calendar.current.isDateBeforeToday(date), let weekday = date.weekday else {
                    return createdProjects
                }

                // 3. If we're today or in future, we want to show projects you've created
                // and recurring projects. If you've created a project on this day from a recurring project
                // we want to make sure not to show more than 1 recurring project.
                // We do that by checking if the created project's recurrence property's ID matches any
                // projects with a recurrence template that has a matching ID
                let recurrenceRulesRequest = FocusProjectRecurrenceEntity.fetchRequest()
                let isInfinitePredicate = NSPredicate(format: "endDate = nil")
                let endDateIsTodayOrInFuture = NSPredicate(format: "endDate >= %@", date as CVarArg)
                recurrenceRulesRequest.predicate = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [isInfinitePredicate, endDateIsTodayOrInFuture]
                )
                recurrenceRulesRequest.sortDescriptors = FocusProjectRecurrenceEntity.defaultSortDescriptors
                return recurrenceClient.monitor(recurrenceRulesRequest)
                    .map { rules in rules.filter { $0.repeatingDays.contains(weekday) }.map(\.templateProjectID) }
                    .eraseToAnyPublisher()
                    .flatMap { [focusProjectRepository] templateProjectIDs in
                        var byTemplateID: [NSPredicate] = []
                        for id in templateProjectIDs {
                            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
                            byTemplateID.append(predicate)
                        }
                        let templateProjectsRequest = FocusProjectEntity.fetchRequest()
                        templateProjectsRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: byTemplateID)
                        templateProjectsRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
                        return focusProjectRepository.monitor(templateProjectsRequest)
                            .eraseToAnyPublisher()
                    }
                    .prepend([] as [FocusProject])
                    .combineLatest(createdProjects.prepend([] as [FocusProject]))
                    .map { templateProjects, createdProjects in
                        let templateProjects = templateProjects.filter { templateProject in
                            return !createdProjects.contains(where: { $0.recurrence?.id == templateProject.recurrenceTemplate?.id })
                        }
                        return createdProjects + templateProjects
                    }
                    .eraseToAnyPublisher()
            },
            monitorActivityTotals: {
                let projectsRequest = FocusProjectEntity.fetchRequest()
                let isNotTemplate = NSPredicate(format: "recurrenceTemplate = nil")
                projectsRequest.predicate = isNotTemplate
                projectsRequest.sortDescriptors = FocusProjectEntity.defaultSortDescriptors
                return focusProjectRepository.monitor(projectsRequest)
                    .map { projects in
                        return ActivityTotals(
                            numberOfProjects: projects.count,
                            workSecondsElapsed: projects.map(\.totalWorkSecondsElapsed).reduce(0, +),
                            breakSecondsElapsed: projects.map(\.totalBreakSecondsElapsed).reduce(0, +)
                        )
                    }
                    .eraseToAnyPublisher()
            },
            monitorWeeklyActivityTotals: { day in
                let thisWeekDateRange: (Date, Date) = (day.startOfWeek, day.endOfWeek)
                let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: day)!
                let lastWeekDateRange: (Date, Date) = (lastWeekDate.startOfWeek, lastWeekDate.endOfWeek)

                let thisWeekProjects = FocusProjectEntity.fetchRequest()
                thisWeekProjects.predicate = NSPredicate.dateRangePredicate(dateRange: thisWeekDateRange)

                let lastWeeksProjects = FocusProjectEntity.fetchRequest()
                lastWeeksProjects.predicate = NSPredicate.dateRangePredicate(dateRange: lastWeekDateRange)

                let activityTotalsMonitor = focusProjectRepository.monitor(thisWeekProjects)
                    .prepend([])
                    .combineLatest(focusProjectRepository.monitor(lastWeeksProjects).prepend([]))
                    .map { thisWeeksProjects, lastWeeksProjects -> WeeklyActivityTotals in
                        let lastWeeksTotalTime = lastWeeksProjects.map { $0.totalTimeElapsed }.reduce(0, +)
                        var totals: WeeklyActivityTotals = .init()
                        totals.lastWeekTotals = lastWeeksTotalTime
                        for day in WeekDay.allCases {
                            let projects = thisWeeksProjects.filter { $0.creationDate.weekday == day }
                            let totalTimeForDay = projects.map(\.totalTimeElapsed).reduce(0, +)
                            totals.totals[day] = totalTimeForDay
                        }
                        return totals
                    }
                    .eraseToAnyPublisher()
                return activityTotalsMonitor
            },
            monitorProjectsInWeek: { week in
                let projectsRequest = FocusProjectEntity.fetchRequest()
                projectsRequest.predicate = NSPredicate.dateRangePredicate(dateRange: (week.referenceDate.startOfWeek, week.referenceDate.endOfWeek))
                return focusProjectRepository.monitor(projectsRequest)
                    .map { $0.filter { !$0.isRecurrenceTemplate } }
                    .eraseToAnyPublisher()
            },
            update: { id, updateProject in
                let fetchRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(id: id)
                try await focusProjectRepository.updateOne(fetchRequest) { entity, context in
                    guard var project = entity?.toNonManagedObject() else { return }
                    updateProject(&project)
                    entity?.update(from: project, context: context)
                }
            },
            updateProject: { project in
                // 1. Update all basic project properties
                let fetchProjectRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(id: project.id)
                try await focusProjectRepository.updateOne(fetchProjectRequest) { entity, context in
                    entity?.update(from: project, context: context)
                    if project.recurrenceTemplate == nil && entity?.recurrenceTemplate != nil {
                        context.delete(entity!.recurrenceTemplate!)
                    }
                }

                // 2. Update the recurrence template if needed.
                // Create a new recurring project if needed
                if let recurrence = project.recurrence {
                    let recurrenceRequest: NSFetchRequest<FocusProjectRecurrenceEntity> = FocusProjectRecurrenceEntity.fetchByID(
                        id: recurrence.id
                    )

                    let fetchTemplateProjectRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(
                        id: recurrence.templateProjectID
                    )
                    try await focusProjectRepository.updateOne(fetchTemplateProjectRequest) { templateProject, context in
                        let templateID = templateProject?.id
                        templateProject?.update(from: project, context: context)
                        templateProject?.id = templateID
                        templateProject?.isActive = false
                    }

                    try await recurrenceRelationshipRepository.updateRelationship(
                        recurrenceRequest,
                        fetchProjectRequest
                    ) { recurrenceEntities, projectEntities in
                        guard let projectEntity = projectEntities.first else { return }
                        guard let recurrenceEntity = recurrenceEntities.first else { return }

                        recurrenceEntity.addToInstances(projectEntity)
                    }

                    try await recurrenceClient.updateOne(recurrenceRequest) { entity, context in
                        entity?.update(from: recurrence, context: context)
                    }
                }

                // 3. Update activity goals
                let fetchActivityGoalsRequest: NSFetchRequest<ActivityGoalEntity> = ActivityGoalEntity.fetchByIDs(
                    ids: project.activityGoals.map(\.id)
                )

                try await activityGoalRelationshipRepository.updateRelationship(
                    fetchActivityGoalsRequest,
                    fetchProjectRequest
                ) { activityGoals, projects in
                    guard let projectEntity = projects.first else { return }
                    let existingActivityGoalEntities = (projectEntity.activityGoals ?? .init()).compactMap { $0 as? ActivityGoalEntity }
                    for existing in existingActivityGoalEntities {
                        projectEntity.removeFromActivityGoals(existing)
                    }

                    for activityGoal in activityGoals {
                        projectEntity.addToActivityGoals(activityGoal)
                    }
                }
            },
            updateActiveProject: { updateProject in
                let fetchRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchIsActiveRequest(true)
                try await focusProjectRepository.updateOne(fetchRequest) { entity, context in
                    guard var project = entity?.toNonManagedObject() else { return }
                    updateProject(&project)
                    entity?.update(from: project, context: context)
                }
            },
            updateAllProjectsInactive: {
                let setOtherProjectsInactiveRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchIsActiveRequest(true)
                try await focusProjectRepository.update(setOtherProjectsInactiveRequest) { entities in
                    for entity in entities {
                        entity.isActive = false
                        (entity.timer as? StandardTimerEntity)?.isRunning = false
                        (entity.timer as? StopwatchTimerEntity)?.isRunning = false
                    }
                }
            },
            deleteProject: { project in
                let request: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(id: project.id)
                try await focusProjectRepository.deleteOne(request)
            },
            deleteRecurrence: { recurrence in
                // This cancels all future recurrences
                let request: NSFetchRequest<FocusProjectRecurrenceEntity> = FocusProjectRecurrenceEntity.fetchByID(id: recurrence.id)
                try await recurrenceClient.delete(request)
                let templateRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchByID(id: recurrence.templateProjectID)
                try await focusProjectRepository.delete(templateRequest)
            },
            deleteAllRecurringProjectInstances: { recurrence in
                // This cancels all future recurrences and deletes all instances of the recurring project
                let deleteProjectRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchRequest()
                deleteProjectRequest.predicate = .init(format: "recurrence.id == %@", recurrence.id as CVarArg)
                try await focusProjectRepository.delete(deleteProjectRequest)
                let deleteTemplateRequest: NSFetchRequest<FocusProjectEntity> = FocusProjectEntity.fetchRequest()
                deleteTemplateRequest.predicate = .init(format: "recurrenceTemplate.id == %@", recurrence.id as CVarArg)
                try await focusProjectRepository.delete(deleteTemplateRequest)

                let deleteRecurrenceRequest: NSFetchRequest<FocusProjectRecurrenceEntity> = FocusProjectRecurrenceEntity.fetchRequest()
                deleteRecurrenceRequest.predicate = .init(format: "id == %@", recurrence.id as CVarArg)
                try await recurrenceClient.delete(deleteRecurrenceRequest)
            }
        )
    }
}

extension FocusProjectClient: DependencyKey {
    static let liveValue: FocusProjectClientType = FocusProjectClient.live(
        focusProjectRepository: .live(
            coreDataStack: CoreDataStack.live
        ),
        activityGoalRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
        recurrenceRelationshipRepository: .live(coreDataStack: CoreDataStack.live),
        recurrenceClient: .live(coreDataStack: CoreDataStack.live),
        activityGoalClient: .live(coreDataStack: CoreDataStack.live)
    )

    static let testValue: FocusProjectClientType = MockFocusProjectClient.live()
}

private extension Date {
    var weekday: WeekDay? {
        let day = Calendar.current.component(.weekday, from: self) - 1
        return WeekDay(rawValue: day)

    }
}
