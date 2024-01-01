import Foundation

/// A single piece of work the user is focusing on
struct TodoListTask: Equatable {

    var id: UUID = UUID()

    var title: String = ""

    var order: Int = 0

    var creationDate: Date = Date()

    var inProgress: Bool = false

    var completed: Bool = false
}
