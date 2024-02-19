//
//  FavouriteEntriesPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import CoreData
import Factory
import Foundation

class FavouriteEntriesPersistenceManager {

    // MARK: Internal properties

    let fetchedResultsController: NSFetchedResultsController<ManagedFeedEntry>

    // MARK: Private properties

    private let controllerContext: NSManagedObjectContext

    @Injected(\.feedModelPersistentContainer) private static var persistentContainer

    // MARK: Initialization

    init() {
        let context = Self.persistentContainer.newBackgroundContext()
        controllerContext = context

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Self.newControllerFetchRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    // MARK: Internal methods

    /// Can be called from any thread.
    @discardableResult
    func fetchControllerData() async -> Bool {
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
    func saveControllerData() async -> Bool {
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
                try Self.persistentContainer.viewContext.save()
            } catch {
                return false
            }
            return true
        }
        return succeeded
    }

    // MARK: Private methods

    private static func newControllerFetchRequest() -> NSFetchRequest<ManagedFeedEntry> {
        let fetchRequest = ManagedFeedEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [
                #keyPath(ManagedFeedEntry.isFavourite),
                true
            ]
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedFeedEntry.date, ascending: false)
        ]
        return fetchRequest
    }
}
