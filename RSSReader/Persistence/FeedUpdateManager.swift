//
//  FeedUpdateManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import Foundation

class FeedUpdateManager {

    // MARK: Internal properties

    let feedPersistenceManager: FeedPersistenceManager

    // MARK: Private properties

    private let feedService: FeedService

    // MARK: Initialization

    convenience init(url: URL) {
        let feedService = FeedService()
        let feedPersistenceManager = FeedPersistenceManager(activeURL: url)
        self.init(
            feedService: feedService,
            feedPersistenceManager: feedPersistenceManager
        )
    }

    init(
        feedService: FeedService,
        feedPersistenceManager: FeedPersistenceManager
    ) {
        self.feedService = feedService
        self.feedPersistenceManager = feedPersistenceManager
    }

    // MARK: Internal methods

    func update() {

    }

}
