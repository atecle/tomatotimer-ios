import Foundation
import CoreData

extension ToDoListTaskEntity: ManagedObject {

    static var defaultSortDescriptors: [NSSortDescriptor] { [] }

    func toNonManagedObject() -> TodoListTask? {
        return TodoListTask(entity: self)
    }

    func update(from nonManagedObject: TodoListTask, context: NSManagedObjectContext) {
        id = nonManagedObject.id
        title = nonManagedObject.title
        creationDate = nonManagedObject.creationDate
        inProgress = nonManagedObject.inProgress
        completed = nonManagedObject.completed
    }
}

extension TodoListTask {

    init?(entity: ToDoListTaskEntity) {
        guard
            let id = entity.id,
            let title = entity.title,
            let creationDate = entity.creationDate else {
            return nil
        }

        self.init(
            id: id,
            title: title,
            order: Int(entity.order),
            creationDate: creationDate,
            inProgress: entity.inProgress,
            completed: entity.completed
        )
    }
}
