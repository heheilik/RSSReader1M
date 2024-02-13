//
//  FeedPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import Factory
import FeedKit
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

    /// Must be called on main thread.
    @discardableResult
    func fetchControllerData() -> Bool {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            return false
        }
        return true
    }

    /// Must be called on main thread.
    @discardableResult
    func saveControllerData() -> Bool {
        do {
            try Self.persistentContainer.viewContext.save()
        } catch {
            return false
        }
        return true
    }

    func insert(feed downloadedFeed: RSSFeed, downloadedAt url: URL) async {
        let context = Self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.rollback
        
        context.performAndWait {
            // fetching feed
            let feed = fetchFeed(by: url, in: context)

            // updating feed with downloaded data
            if let feed {
                merge(downloadedFeed: downloadedFeed, into: feed, in: context)
            } else {
                createFeed(from: downloadedFeed, downloadedAt: url, in: context)
            }

            // saving changes
            if context.hasChanges {
                try? context.save()
            }
        }

        _ = await MainActor.run {
            saveControllerData()
        }

        // TODO: perform fetch if needed
    }

    @MainActor
    func fetchUnreadEntriesCount(for url: URL) async -> Int? {
        // creating expression
        let countExpression = NSExpression(
            forFunction: "count:",
            arguments: [NSExpression(forKeyPath: #keyPath(ManagedFeedEntry.isRead))]
        )

        // creating expression description
        let key = "count"
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = key
        expressionDescription.expression = countExpression
        if #available(iOS 15, *) {
            expressionDescription.resultType = .integer64
        } else {
            expressionDescription.expressionResultType = .integer64AttributeType
        }

        // creating fetch predicate
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            argumentArray: [
                #keyPath(ManagedFeedEntry.feed.url),
                url,
                #keyPath(ManagedFeedEntry.isRead),
                false
            ]
        )

        // creating fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ManagedFeedEntry.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.propertiesToFetch = [expressionDescription]
        fetchRequest.resultType = .dictionaryResultType

        // running fetch and acquiring result
        do {
            let result = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            guard let int64Result = (result as? [[String: Int64]])?.first?[key] else {
                return nil
            }
            return Int(int64Result)
        } catch {
            print(error)
            return nil
        }
    }

    // MARK: Private methods
    
    /// Must be called on private queue of context.
    private func merge(
        downloadedFeed: RSSFeed,
        into feed: ManagedFeed,
        in context: NSManagedObjectContext
    ) {
        guard let entries = feed.entries as? Set<ManagedFeedEntry> else {
            return
        }

        // removing entries that are already contained by database
        downloadedFeed.items = downloadedFeed.items?.filter { item in
            !entries.contains { $0.title == item.title }
        }

        // creating new entries in context
        downloadedFeed.items?.forEach {
            let managedFeedEntry = ManagedFeedEntry(context: context)
            guard managedFeedEntry.fill(with: $0) else {
                context.delete(managedFeedEntry)
                return
            }
            feed.addToEntries(managedFeedEntry)
        }
    }
    
    /// Must be called on private queue of context.
    private func createFeed(
        from downloadedFeed: RSSFeed,
        downloadedAt url: URL,
        in context: NSManagedObjectContext
    ) {
        let feed = ManagedFeed(context: context)
        guard feed.fill(with: downloadedFeed, url: url) else {
            context.delete(feed)
            return
        }
    }

    private func fetchFeed(by url: URL, in context: NSManagedObjectContext) -> ManagedFeed? {
        let fetchRequest = ManagedFeed.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [
                #keyPath(ManagedFeed.url),
                url
            ]
        )
        return try? context.fetch(fetchRequest).first
    }

    private static func newPredicateTemplate() -> NSPredicate {
        NSPredicate(format: "\(#keyPath(ManagedFeedEntry.feed.url)) == $\(SubstitutableVariables.url)")
    }
}
