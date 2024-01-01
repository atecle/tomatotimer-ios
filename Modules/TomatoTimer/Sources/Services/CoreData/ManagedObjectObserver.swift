import Foundation
import CoreData
import Combine

// swiftlint:disable line_length

// Code adapted from:
// https://gist.githubusercontent.com/andreyz/757ec98b5e567cddd5ff55e1fd2c1e19/raw/c2e4638861bb39b77dcca72a29f29a3c2bacc559/ManagedObjectChangesPublisher.swift

extension NSManagedObjectContext {
    func changesPublisher<Object: ManagedObject>(for fetchRequest: NSFetchRequest<Object>) -> ManagedObjectChangesPublisher<Object> {
        ManagedObjectChangesPublisher(fetchRequest: fetchRequest, context: self)
    }
}

struct ManagedObjectChangesPublisher<Object: ManagedObject>: Publisher {
    typealias Output = CollectionDifference<Object.NonManaged>
    typealias Failure = Error

    let fetchRequest: NSFetchRequest<Object>
    let context: NSManagedObjectContext

    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        let inner = Inner(downstream: subscriber, fetchRequest: fetchRequest, context: context)
        subscriber.receive(subscription: inner)
    }

    private final class Inner<
        Downstream: Subscriber
    >: NSObject, Subscription, NSFetchedResultsControllerDelegate where Downstream.Input == CollectionDifference<Object.NonManaged>, Downstream.Failure == Error {

        private let downstream: Downstream
        private var fetchedResultsController: NSFetchedResultsController<Object>?
        private var demand: Subscribers.Demand = .none
        override var description: String {
            "ManagedObjectChanges(\(Object.self))"
        }
        private var lastSentState: [Object.NonManaged] = []
        private var currentDifferences = CollectionDifference<Object.NonManaged>([])!

        init(
            downstream: Downstream,
            fetchRequest: NSFetchRequest<Object>,
            context: NSManagedObjectContext
        ) {
            self.downstream = downstream
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            fetchedResultsController!.delegate = self

            do {
                try fetchedResultsController!.performFetch()
                updateDiff()
            } catch {
                downstream.receive(completion: .failure(error))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
            fulfillDemand()
        }

        private func updateDiff() {
            let currentState = fetchedResultsController?.fetchedObjects?.compactMap { $0.toNonManagedObject() } ?? []
            currentDifferences = currentState.difference(from: lastSentState)
            fulfillDemand()
        }

        private func fulfillDemand() {
            guard demand > 0 && !currentDifferences.isEmpty else {
                return
            }

            let newDemand = downstream.receive(currentDifferences)
            lastSentState = fetchedResultsController?.fetchedObjects?.compactMap { $0.toNonManagedObject() } ?? []
            currentDifferences = lastSentState.difference(from: lastSentState)
            demand += newDemand
            demand -= 1
        }

        func cancel() {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }

        func controllerDidChangeContent(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
            updateDiff()
        }

    }
}
