//
//  FeedPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import Factory
import Foundation

class FeedPersistenceManager {

    // MARK: Constants

    private enum SubstitutableVariables {
        static let url = "url"
    }

    // MARK: Internal properties

    let fetchedResultsController: NSFetchedResultsController<ManagedFeedEntry>

    // MARK: Private properties

    @Injected(\.feedModelPersistentContainer) private static var persistentContainer

    private static let falseFetchRequest = {
        let fetchRequest = ManagedFeedEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "FALSEPREDICATE")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedFeedEntry.date, ascending: false)
        ]
        return fetchRequest
    }()

    // MARK: Initialization

    convenience init() {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Self.falseFetchRequest,
            managedObjectContext: Self.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(
            fetchedResultsController: fetchedResultsController
        )
    }

    convenience init(activeURL: URL) {
        let fetchRequest = Self.falseFetchRequest
        fetchRequest.predicate = Self.newPredicateTemplate().withSubstitutionVariables([
            SubstitutableVariables.url: activeURL
        ])

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: Self.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(
            fetchedResultsController: fetchedResultsController
        )
    }

    init(
        fetchedResultsController: NSFetchedResultsController<ManagedFeedEntry>
    ) {
        self.fetchedResultsController = fetchedResultsController
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
        NSPredicate(format: "\(#keyPath(ManagedFeedEntry.feed.url)) == $\(SubstitutableVariables.url)")
    }
}
