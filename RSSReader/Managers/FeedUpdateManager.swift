//
//  FeedUpdateManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 14.02.24.
//

import FeedKit
import Foundation

class FeedUpdateManager {

    // MARK: Constants

    enum UpdateError: Error {
        case workInProgress
        case downloadFailed
        case wrongFeedType
    }

    // MARK: Internal properties

    private(set) var workInProgress = false
    private(set) var error: UpdateError?

    // MARK: Private properties

    private let persistenceManager: FeedPersistenceManager
    private let feedService: FeedService

    // MARK: Initialization

    init(
        persistenceManager: FeedPersistenceManager,
        feedService: FeedService = FeedService()
    ) {
        self.persistenceManager = persistenceManager
        self.feedService = feedService
    }

    // MARK: Internal methods

    func updateFeed() async -> Result<Void, UpdateError> {
        guard !workInProgress else {
            return .failure(.workInProgress)
        }

        error = nil
        workInProgress = true
        defer {
            workInProgress = false
        }

        let feed: RSSFeed
        switch await downloadFeed(at: persistenceManager.url) {
        case let .failure(error):
            return .failure(error)
        case let .success(rssFeed):
            feed = rssFeed
        }

        await persistenceManager.insert(feed: feed, downloadedAt: persistenceManager.url)
        return .success
    }

    // MARK: Private methods

    private func downloadFeed(at url: URL) async -> Result<RSSFeed, UpdateError> {
        guard let feed = await feedService.prepareFeed(at: url) else {
            return .failure(.downloadFailed)
        }

        switch feed {
        case let .rss(rssFeed):
            return .success(rssFeed)
        case .atom(_), .json(_):
            return .failure(.wrongFeedType)
        }
    }
}
