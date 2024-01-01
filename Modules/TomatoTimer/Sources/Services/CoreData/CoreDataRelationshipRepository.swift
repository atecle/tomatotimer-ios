import Foundation
import CoreData
import Combine
import ComposableArchitecture

struct CoreDataRelationshipRepository<T: ManagedObject, S: ManagedObject> {

    // MARK: Update

    var updateRelationship: (NSFetchRequest<T>, NSFetchRequest<S>, @escaping ([T], [S]) -> Void) async throws -> Void

    static func live(
        coreDataStack: CoreDataStackType
    ) -> Self {
        Self(
            updateRelationship: { updateRequest, fetchRequest, completion in
                try await coreDataStack.updateRelationship(
                    updateRequest: updateRequest,
                    fetchRequest: fetchRequest,
                    completion
                )
            }
        )
    }
}
