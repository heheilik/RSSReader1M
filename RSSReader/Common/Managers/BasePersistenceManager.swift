//
//  BasePersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import CoreData

class BasePersistenceManager<ManagedObject: NSManagedObject> {

    // MARK: Public properties

    public let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    public let controllerContext: NSManagedObjectContext

    public let persistentContainer: NSPersistentContainer

    // MARK: Initialization

    public init(
        persistentContainer: NSPersistentContainer,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) {
        self.persistentContainer = persistentContainer
        controllerContext = persistentContainer.newBackgroundContext()

        let fetchRequest = NSFetchRequest<ManagedObject>()
        fetchRequest.entity = ManagedObject.entity()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        fetchedResultsController = NSFetchedResultsController<ManagedObject>(
            fetchRequest: fetchRequest,
            managedObjectContext: controllerContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    // MARK: Public methods

    /// Can be called from any thread.
    @discardableResult
    public func fetchControllerData() async -> Bool {
        var succeeded = false
        controllerContext.performAndWait {
            do {
                try fetchedResultsController.performFetch()
            } catch {
                return
            }
            succeeded = true
        }
        return succeeded
    }

    /// Can be called from any thread.
    @discardableResult
    public func saveControllerData() async -> Bool {
        var succeeded = false
        controllerContext.performAndWait {
            do {
                try controllerContext.save()
            } catch {
                succeeded = false
            }
        }
        guard succeeded else {
            return false
        }

        succeeded = await MainActor.run {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                return false
            }
            return true
        }
        return succeeded
    }
}
