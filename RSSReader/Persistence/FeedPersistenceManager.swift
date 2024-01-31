//
//  FeedPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import Foundation

class FeedPersistenceManager {

    // MARK: Constants

    private enum ModelNames {
        static let feedEntry = "FeedModel"
    }

    private enum SubstitutableVariables {
        static let url = "url"
    }

    // MARK: Internal properties

    let fetchedResultsController: NSFetchedResultsController<FeedEntry>
    let persistentContainer: NSPersistentContainer

    // MARK: Private properties

    private static let falseFetchRequest = {
        let fetchRequest = FeedEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "FALSEPREDICATE")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FeedEntry.orderID, ascending: false),
            NSSortDescriptor(keyPath: \FeedEntry.date, ascending: false)
        ]
        return fetchRequest
    }()

    // MARK: Initialization

    convenience init() {
        let persistentContainer = NSPersistentContainer(name: ModelNames.feedEntry)

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Self.falseFetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(
            persistentContainer: NSPersistentContainer(name: ModelNames.feedEntry),
            fetchedResultsController: fetchedResultsController
        )
    }

    convenience init(activeURL: URL) {
        let persistentContainer = NSPersistentContainer(name: ModelNames.feedEntry)

        let fetchRequest = Self.falseFetchRequest
        fetchRequest.predicate = Self.newPredicateTemplate().withSubstitutionVariables([
            SubstitutableVariables.url: activeURL
        ])

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(
            persistentContainer: persistentContainer,
            fetchedResultsController: fetchedResultsController
        )
    }

    init(
        persistentContainer: NSPersistentContainer,
        fetchedResultsController: NSFetchedResultsController<FeedEntry>
    ) {
        self.fetchedResultsController = fetchedResultsController
        self.persistentContainer = persistentContainer
        try? fetchedResultsController.performFetch()
    }

    // MARK: Internal methods

    func changeActiveURL(to url: URL) {
        fetchedResultsController.fetchRequest.predicate = Self.newPredicateTemplate().withSubstitutionVariables([
            SubstitutableVariables.url: url
        ])
        try? fetchedResultsController.performFetch()
    }

    // MARK: Private methods

    private static func newPredicateTemplate() -> NSPredicate {
        NSPredicate(format: "\(#keyPath(FeedEntry.feed.url)) == $\(SubstitutableVariables.url)")
    }
}
