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

    // MARK: Internal properties

    let fetchedResultsController: NSFetchedResultsController<ManagedFeedEntry>
    let url: URL

    // MARK: Private properties

    private let controllerContext: NSManagedObjectContext

    @Injected(\.feedModelPersistentContainer) private static var persistentContainer

    // MARK: Initialization

    init(url: URL) {
        self.url = url

        let context = Self.persistentContainer.newBackgroundContext()
        controllerContext = context
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Self.newControllerFetchRequest(for: url),
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

    func insert(feed downloadedFeed: RSSFeed, downloadedAt url: URL) async {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = controllerContext
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

        await saveControllerData()
    }

    // TODO: Rewrite to use concurrency
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
    
    private static func newControllerFetchRequest(for url: URL) -> NSFetchRequest<ManagedFeedEntry> {
        let fetchRequest = ManagedFeedEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [
                #keyPath(ManagedFeedEntry.feed.url),
                url
            ]
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ManagedFeedEntry.date, ascending: false)
        ]
        return fetchRequest
    }
}
