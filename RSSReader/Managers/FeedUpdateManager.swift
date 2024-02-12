//
//  FeedUpdateManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import FeedKit
import Foundation

class FeedUpdateManager {

    // MARK: Constants

    enum UpdateError: Error {
        case feedNotDownloaded
        case wrongFeedType
        case parsingToManagedError
        case fetchError
        case saveError
        case controllerUpdatingError
    }

    // MARK: Internal properties

    static let newFeedComparatorClosure: (RSSFeedItem, RSSFeedItem) -> Bool = {
        guard let firstDate = $0.pubDate else {
            return false
        }
        guard let secondDate = $1.pubDate else {
            return true
        }
        return firstDate < secondDate
    }

    let feedPersistenceManager: FeedPersistenceManager

    let url: URL

    var error: UpdateError?

    var unreadEntriesCount: Int?

    // MARK: Private properties

    private let feedService: FeedService

    private var downloadedFeed: RSSFeed?


    // MARK: Initialization

    convenience init(url: URL) {
        let feedService = FeedService()
        let feedPersistenceManager = FeedPersistenceManager(activeURL: url)
        self.init(
            url: url,
            feedService: feedService,
            feedPersistenceManager: feedPersistenceManager
        )
    }

    init(
        url: URL,
        feedService: FeedService,
        feedPersistenceManager: FeedPersistenceManager
    ) {
        self.url = url
        self.feedService = feedService
        self.feedPersistenceManager = feedPersistenceManager
    }

    // MARK: Internal methods

    func update() async {
        // Acquiring data
        print("Acquiring data...")
        guard await acquireData() else {
            return
        }

        // Processing data
        print("Processing data...")
        print("  Removing old entries from downloaded data...")
        removeOldEntriesFromDownloadedFeed()

        print("  Writing results to disk...")
        guard await updateStoredFeed() else {
            return
        }

        // Getting unread entries count
        guard let unreadEntriesCount = await fetchUnreadEntriesCount(for: url) else {
            return
        }
        self.unreadEntriesCount = unreadEntriesCount

        // Updating fetchedResultsController
        print("Updating fetchedResultsController...")
        await MainActor.run { [weak self] in
            guard let self = self else {
                return
            }
            do {
                try self.feedPersistenceManager.fetchedResultsController.performFetch()
            } catch {
                self.error = .controllerUpdatingError
            }
        }

        // Checking if controller update succeeded
        print("Checking if controller update succeeded...")
        guard error == nil else {
            return
        }

        print("Update completed")
    }

    // MARK: Private methods

    /// Downloads data from web and fetches data from persistent store.
    /// - Returns: `true` if operation succeeded, otherwise `false`.
    private func acquireData() async -> Bool {
        // Start feed downloading
        print("  Started feed downloading...")
        async let downloadedFeed = downloadRSSFeed()

        // Fetch data and check fetched data
        print("  Fetching data...")
        guard await fetchFeed() else {
            self.error = .fetchError
            // TODO: Cancel downloading
            return false
        }

        // Check downloaded data
        print("  Checking downloaded data...")
        switch await downloadedFeed {
        case let .failure(error):
            self.error = error
            return false

        case let .success(feed):
            self.downloadedFeed = feed
            return true
        }
    }

    /// Downloads feed from web and checks if it's type is RSS.
    private func downloadRSSFeed() async -> Result<RSSFeed, UpdateError> {
        let feed = await feedService.prepareFeed(at: url)
        guard let feed else {
            return .failure(.feedNotDownloaded)
        }

        switch feed {
        case let .rss(feed):
            return .success(feed)
        case .atom, .json:
            return .failure(.wrongFeedType)
        }
    }

    /// Fetches data from persistent store.
    /// - Returns: `true` if operation succeeded, otherwise `false`.
    @MainActor
    private func fetchFeed() async -> Bool {
        do {
            try self.feedPersistenceManager.fetchedResultsController.performFetch()
        } catch {
            self.error = .fetchError
            return false
        }
        return true
    }

    private func removeOldEntriesFromDownloadedFeed() {
        downloadedFeed?.items = downloadedFeed?.items?.filter { [weak self] item in
            self?.feedPersistenceManager.fetchedResultsController.fetchedObjects?.contains {
                $0.title == item.title
            } != true
        }
    }

    @MainActor
    private func updateStoredFeed() async -> Bool {
        guard
            let downloadedFeed,
            let downloadedFeedEntries = downloadedFeed.items
        else {
            return false
        }

        if let existingManagedFeed = feedPersistenceManager.fetchedResultsController.fetchedObjects?.first?.feed {
            // Formatting downloaded entries
            let newFormattedManagedFeedEntries = formattedDownloadEntries(
                context: feedPersistenceManager.fetchedResultsController.managedObjectContext,
                items: downloadedFeedEntries
            )
            print("    Downloaded \(newFormattedManagedFeedEntries.count) new feed entries.")

            // Adding formatted entries to existing feed
            existingManagedFeed.addToEntries(NSSet(array: newFormattedManagedFeedEntries))
        } else {
            print("    Downloaded totally new feed.")

            // Creating new feed
            let newManagedFeed = ManagedFeed(
                context: feedPersistenceManager.fetchedResultsController.managedObjectContext
            )

            // Filling feed with downloaded data
            guard newManagedFeed.fill(
                with: downloadedFeed,
                url: url
            ) else {
                self.error = .parsingToManagedError
                return false
            }
        }

        print("    Finally saving...")
        do {
            try feedPersistenceManager.fetchedResultsController.managedObjectContext.save()
        } catch {
            self.error = .saveError
            return false
        }
        return true
    }

    @MainActor
    private func formattedDownloadEntries(
        context: NSManagedObjectContext,
        items: [RSSFeedItem]
    ) -> [ManagedFeedEntry] {
        return items
            .sorted(by: Self.newFeedComparatorClosure)
            .compactMap { item in
                let managedFeedEntry = ManagedFeedEntry(context: context)
                guard managedFeedEntry.fill(with: item) else {
                    return nil
                }
                return managedFeedEntry
            }
    }

    @MainActor
    private func fetchUnreadEntriesCount(for url: URL) async -> Int? {
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
            let result = try feedPersistenceManager.fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            guard let int64Result = (result as? [[String: Int64]])?.first?[key] else {
                return nil
            }
            return Int(int64Result)
        } catch {
            print(error)
            return nil
        }
    }
}
