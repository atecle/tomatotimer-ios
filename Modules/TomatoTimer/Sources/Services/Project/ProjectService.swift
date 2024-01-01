//
//  TodoService.swift
//  TomatoTimer
//
//  Created by adam on 2/8/20.
//  Copyright © 2020 Adam Tecle. All rights reserved.
//

import Foundation
import Combine

protocol ProjectServiceProvider {
    var projectService: ProjectServiceType { get }
}

protocol ProjectServiceType {

    func fetchAll() async throws -> [TodoListProject]

    func monitor() -> AnyPublisher<[TodoListProject], Error>

    func currentProject() -> AnyPublisher<TodoListProject, Error>

    func add(_ project: TodoListProject) async throws

    func update(_ project: TodoListProject) async throws

    func delete(_ project: TodoListProject) async throws

}

struct ProjectService: ProjectServiceType {

    private let repository: Repository<ToDoListProjectEntity>

    init(
        repository: Repository<ToDoListProjectEntity>
    ) {
        self.repository = repository
    }

    func fetchAll() async throws -> [TodoListProject] {
        let fetch = ToDoListProjectEntity.fetchRequest()
        fetch.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        return try await repository.fetchAll(fetch)
    }

    func currentProject() -> AnyPublisher<TodoListProject, Error> {
        let fetch = ToDoListProjectEntity.fetchRequest()
        fetch.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        return repository.monitor(fetch)
            .compactMap { $0.first(where: \.isActive) }
            .eraseToAnyPublisher()
    }

    func monitor() -> AnyPublisher<[TodoListProject], Error> {
        let fetch = ToDoListProjectEntity.fetchRequest()
        fetch.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        return repository.monitor(fetch)
            .map { $0.sorted(by: \.lastOpenedDate) }
            .eraseToAnyPublisher()
    }

    func add(_ project: TodoListProject) async throws {
        try await repository.create(project)
    }

    func update(_ project: TodoListProject) async throws {
        let request = ToDoListProjectEntity.fetchRequest()
        request.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", project.id as CVarArg)
        try await repository.update(fetchRequest: request, nonManaged: project)
    }

    func delete(_ project: TodoListProject) async throws {
        let request = ToDoListProjectEntity.fetchRequest()
        request.sortDescriptors = ToDoListProjectEntity.defaultSortDescriptors
        request.predicate = .init(format: "%K == %@", "id", project.id as CVarArg)
        try await repository.delete(fetchRequest: request, nonManaged: project)
    }
}
