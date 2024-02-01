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

    let feedPersistenceManager: FeedPersistenceManager

    let url: URL

    var error: UpdateError? {
        didSet {
            print(error)
        }
    }

    // MARK: Private properties

    private let feedService: FeedService

    private var downloadedFeed: RSSFeed?

    private let pubDateAscendingFeedItemComparatorClosure: (RSSFeedItem, RSSFeedItem) -> Bool = {
        guard let firstDate = $0.pubDate else {
            return false
        }
        guard let secondDate = $1.pubDate else {
            return true
        }
        return firstDate < secondDate
    }

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
        let dataAcquired = await acquireData()
        guard dataAcquired else {
            return
        }

        // Processing data
        print("Processing data...")
        print("  Removing old entries from downloaded data...")
        removeOldEntriesFromDownloadedFeed()

        print("  Writing results to disk...")
        guard updateStoredFeed() else {
            return
        }

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
        let fetchSucceded = await fetchFeed()
        print("  Checking fetched data...")
        guard fetchSucceded else {
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

    private func updateStoredFeed() -> Bool {
        guard
            let downloadedFeed,
            let downloadedFeedEntries = downloadedFeed.items
        else {
            return false
        }

        // managedFeed doesn't exist on first download
        if let existingManagedFeed = feedPersistenceManager.fetchedResultsController.fetchedObjects?.first?.feed {
            print("")
            let newFormattedManagedFeedEntries = formattedDownloadEntries(
                context: feedPersistenceManager.fetchedResultsController.managedObjectContext,
                items: downloadedFeedEntries,
                lastReadOrderID: existingManagedFeed.lastReadOrderID
            )
            existingManagedFeed.addToEntries(NSSet(array: newFormattedManagedFeedEntries))
        } else {
            let newManagedFeed = ManagedFeed(context: feedPersistenceManager.fetchedResultsController.managedObjectContext)
            guard newManagedFeed.fill(
                with: downloadedFeed,
                url: url
            ) else {
                self.error = .parsingToManagedError
                return false
            }
        }

        do {
            try feedPersistenceManager.fetchedResultsController.managedObjectContext.save()
        } catch {
            self.error = .saveError
            return false
        }
        return true
    }

    private func formattedDownloadEntries(
        context: NSManagedObjectContext,
        items: [RSSFeedItem],
        lastReadOrderID: Int64
    ) -> [ManagedFeedEntry] {
        var currentOrderID = lastReadOrderID + 1
        return items
            .sorted(by: pubDateAscendingFeedItemComparatorClosure)
            .compactMap { item in
                let managedFeedEntry = ManagedFeedEntry(context: context)
                guard managedFeedEntry.fill(with: item, orderID: currentOrderID) else {
                    return nil
                }
                currentOrderID += 1
                return managedFeedEntry
            }
    }
}
