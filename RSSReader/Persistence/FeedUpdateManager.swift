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
    }

    // MARK: Internal properties

    let feedPersistenceManager: FeedPersistenceManager

    let url: URL

    // MARK: Private properties

    private let feedService: FeedService

    private var downloadedFeed: ManagedFeed?

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
        let dataAcquired = await acquireData()
        guard dataAcquired else {
            return false
        }
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
        let rssFeed: RSSFeed
        switch await downloadedFeed {
        case let .failure(error):
            self.error = error
            return false
        case let .success(feed):
            rssFeed = feed
        }

        // Parse downloaded feed to managed objects
        guard let parsedFeed = parsedFeed(from: rssFeed) else {
            self.error = .parsingToManagedError
            return false
        }
        self.downloadedFeed = parsedFeed

        return true
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
        fatalError("Not implemented.", file: #file, line: #line)
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

    }

    private func formatDownloadedFeed() {

    }

    private func updateStoredFeed() {

    }

    private func managedFeed(from rssFeed: RSSFeed) -> ManagedFeed? {
        let context = feedPersistenceManager.persistentContainer.newBackgroundContext()
        let managedFeed = ManagedFeed(context: context)

        if let urlString = rssFeed.image?.link,
           let url = URL(string: urlString) {
            managedFeed.imageLink = url
        }
        managedFeed.url = url
        managedFeed.lastReadOrderID = -1

        guard
            let managedEntriesSet = rssFeed.items?.reduce(Set<ManagedFeedEntry>(), { partialResult, item in
                guard let item = managedFeedEntry(from: item) else {
                    return partialResult
                }
                var partialResult = partialResult
                partialResult.insert(item)
                return partialResult
            }) as? NSSet
        else {
            return nil
        }
        managedFeed.addToEntries(managedEntriesSet)

        return managedFeed
    }
}
