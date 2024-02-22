//
//  MockFeedService.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import FeedKit
import Foundation
@testable import RSSReader

final class MockFeedService: FeedService {

    var prepareFeedCalled = false

    override func prepareFeed(at url: URL) async -> Feed? {
        prepareFeedCalled = true
        return MockFeedFactory.feedForUrl(url)
    }

}
