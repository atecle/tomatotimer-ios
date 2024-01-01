import CoreData
import XCTest

@testable import TomatoTimer

// swiftlint:disable all

open class CoreDataTestCase<P: NSPersistentContainer>: XCTestCase {

    public private(set) var persistentContainer: P!

    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    open func targetBundle() -> Bundle {
        return Bundle.main
    }

    open override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        persistentContainer = try .testCasePersistentContainer(
            forModelInBundle: targetBundle()
        )

        CoreDataStack.createStack(container: persistentContainer)
    }

    open override func tearDown() async throws {
        try await persistentContainer?.destroyPersistentStore()
        persistentContainer = nil

        try super.tearDownWithError()
    }
}

extension NSPersistentContainer {

    func destroyPersistentStore() async throws {
        try await persistentStoreCoordinator.perform {
            guard let persistentStore = self.unwrapPersistentStore() else { return }
            try self.persistentStoreCoordinator.remove(persistentStore)

            guard let fileURL = self.unwrapPersistentStoreURL() else { return }
            try FileManager.default.removeItem(
                at: fileURL.deletingLastPathComponent()
            )
        }
    }

    func unwrapPersistentStore() -> NSPersistentStore? {
        return persistentStoreCoordinator.persistentStores.first
    }

    func unwrapPersistentStoreURL() -> URL? {
        return unwrapPersistentStore()?.url
    }
}

extension NSPersistentContainer {

    static func testCasePersistentContainer<P: NSPersistentContainer>(
        forModelInBundle bundle: Bundle
    ) throws -> P {

        // This is the same function discussed in the article mentioned above.
        //
        // Notice the `uniqueTemporaryDirectory()`.
        let persistentContainer: P = try makePersistentContainer(
            forModelsInBundle: bundle,
            configurator: SQLitePersistentStoreDescriptionConfigurator(
                directory: uniqueTemporaryDirectory(),
                name: bundle.name
            )
        )

        try persistentContainer.loadPersistentStoreOrFail()

        return persistentContainer
    }

    // It's this directory that provides SQLite database isolation.
    static private func uniqueTemporaryDirectory() -> URL {
        return FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private func loadPersistentStoreOrFail() throws {
        loadPersistentStores { _, error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

extension NSPersistentContainer {

    static func makePersistentContainer<P: NSPersistentContainer>(
        named name: String,
        for model: NSManagedObjectModel,
        configurator: PersistentStoreDescriptionConfigurator
    ) throws -> P {
        let persistentContainer = P(name: name, managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        try configurator.configure(description)

        persistentContainer.persistentStoreDescriptions = [
            description
        ]

        return persistentContainer
    }
}

extension NSPersistentContainer {
    static func makePersistentContainer<P: NSPersistentContainer>(
        forModelsInBundle bundle: Bundle,
        configurator: PersistentStoreDescriptionConfigurator
    ) throws -> P {
        return try makePersistentContainer(
            named: bundle.name,
            for: try mergedModel(from: bundle),
            configurator: configurator
        )
    }

    static func mergedModel(from bundle: Bundle) throws -> NSManagedObjectModel {
        guard
            let model = NSManagedObjectModel.mergedModel(from: [bundle]),
            model.entities.count > 0
        else {
            throw MissingModelInBundleError(bundle: bundle)
        }

        return model
    }
}

struct SQLitePersistentStoreDescriptionConfigurator: PersistentStoreDescriptionConfigurator {

    private let fileURL: URL

    init(directory: URL, name: String) {
        let fileURL = directory
            .appendingPathComponent(name, isDirectory: true)
            .appendingPathComponent(name) // this is the file name
            .appendingPathExtension("sqlite")
        self.init(fileURL: fileURL)
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func configure(_ description: NSPersistentStoreDescription) throws {
        description.type = NSSQLiteStoreType

        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.shouldAddStoreAsynchronously = false

        // Set other options here that are relevant to your app.
        // Here are a few examples.
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSSQLiteAnalyzeOption)

        // Create the intermediate directories, if missing.
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        description.url = fileURL
    }
}

protocol PersistentStoreDescriptionConfigurator {

    func configure(_ description: NSPersistentStoreDescription) throws
}

extension Bundle {

    var name: String {
        return stringValue(for: kCFBundleNameKey)
    }

    private func stringValue(for key: CFString) -> String {
        object(forInfoDictionaryKey: key as String) as! String
    }
}

struct MissingModelInBundleError: LocalizedError {

    let bundle: Bundle

    var errorDescription: String? {
        let template = NSLocalizedString(
            "app-error.missing-model-in-bundle-%@",
            tableName: nil,
            bundle: .module,
            value: "",
            comment: ""
        )
        return String(format: template, arguments: [bundle.name])
    }
}
