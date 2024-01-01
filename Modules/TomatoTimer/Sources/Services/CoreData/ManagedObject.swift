import Foundation
import CoreData

protocol ManagedObject: NSManagedObject, NSFetchRequestResult {

    associatedtype NonManaged: Equatable

    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    func toNonManagedObject() -> NonManaged?

    func update(from nonManagedObject: NonManaged, context: NSManagedObjectContext)
}

extension ManagedObject where Self: NSManagedObject {
    static var entityName: String { entity().name! }
}

extension ManagedObject {

    // swiftlint:disable force_cast
    static func fetchByIDs<T: ManagedObject>(ids: [UUID]) -> NSFetchRequest<T> {
        let fetchRequest: NSFetchRequest<T> = Self.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: ids.map { .byID($0 )})
        return fetchRequest
    }

    static func fetchByID<T: ManagedObject>(id: UUID) -> NSFetchRequest<T> {
        let fetchRequest: NSFetchRequest<T> = Self.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = .byID(id)
        return fetchRequest
    }
}
