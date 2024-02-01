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

    private enum UpdateError: Error {
        case feedNotDownloaded
        case wrongFeedType
        case parsingToManagedError
        case fetchError
        case saveError
    }

    // MARK: Internal properties

    let feedPersistenceManager: FeedPersistenceManager

    let url: URL

    // MARK: Private properties

    private let feedService: FeedService

    private var downloadedFeed: RSSFeed?

    private var error: UpdateError?

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
    
    func update() async -> Bool {
        // Acquiring data
        let dataAcquired = await acquireData()
        guard dataAcquired else {
            return false
        }

        // Processing data
        removeOldEntriesFromDownloadedFeed()
        fatalError("Not implemented.", file: #file, line: #line)
    }

    // MARK: Private methods

    /// Downloads data from web and fetches data from persistent store.
    /// - Returns: `true` if operation succeeded, otherwise `false`.
    private func acquireData() async -> Bool {
        // Start feed downloading
        async let downloadedFeed = downloadFeed()

        // Fetch data and check fetched data
        let fetchSucceded = await fetchFeed()
        guard fetchSucceded else {
            self.error = .fetchError
            // TODO: Cancel downloading
            return false
        }

        // Check downloaded data
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
    private func downloadFeed() async -> Result<RSSFeed, UpdateError> {
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

    private func parsedFeed(from rssFeed: RSSFeed) -> ManagedFeed? {
        let context = feedPersistenceManager.persistentContainer.newBackgroundContext()
        let managedFeed = ManagedFeed(context: context)
        return managedFeed.fill(with: rssFeed, url: url) ? managedFeed : nil
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
            let managedFeed = feedPersistenceManager.fetchedResultsController.fetchedObjects?.first?.feed,
            let downloadedFeedEntries = downloadedFeed?.items,
            let newFormattedManagedFeedEntries = formattedDownloadEntries(
                context: feedPersistenceManager.fetchedResultsController.managedObjectContext,
                items: downloadedFeedEntries
            )
        else {
            return false
        }
        managedFeed.addToEntries(NSSet(array: newFormattedManagedFeedEntries))

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
        items: [RSSFeedItem]
    ) -> [ManagedFeedEntry]? {
        fatalError("Not implemented.", file: #file, line: #line)
    }
}
