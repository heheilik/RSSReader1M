//
//  SingleFeedPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import Factory
import FeedKit
import Foundation

final class SingleFeedPersistenceManager: BasePersistenceManager<ManagedFeedEntry> {

    // MARK: Internal properties

    let url: URL

    // MARK: Initialization

    init(url: URL) {
        self.url = url
        super.init(
            persistentContainer: Container.shared.feedModelPersistentContainer(),
            predicate: NSPredicate(
                format: "%K == %@",
                argumentArray: [
                    #keyPath(ManagedFeedEntry.feed.url),
                    url
                ]
            ),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \ManagedFeedEntry.date,
                    ascending: false
                )
            ]
        )
    }

    // MARK: Internal methods

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
        var result: [[String: Int64]]?
        controllerContext.performAndWait {
            result = try? fetchedResultsController.managedObjectContext.fetch(fetchRequest) as? [[String: Int64]]
        }
        guard let count = result?.first?[key] else {
            return nil
        }
        return Int(count)
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
}
