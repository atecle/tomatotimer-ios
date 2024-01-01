import Foundation
import CoreData
import XCTest

@testable import TomatoTimer

// swiftlint:disable force_try
class EntityTestCase: XCTestCase {
    let testCoreDataStack = try! CoreDataStack.createStack(container: .testCasePersistentContainer(forModelInBundle: Bundle.main))
    var context: NSManagedObjectContext { testCoreDataStack.viewContext }

    func test_update() {
    }

    func test_toNonManagedObject() {
    }
}
