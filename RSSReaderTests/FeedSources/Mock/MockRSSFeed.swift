//
//  MockRSSFeed.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FeedKit
import Foundation

extension RSSFeed {

    static let mock: RSSFeed = {
        let feed = RSSFeed()

        feed.title = "Test"
        feed.description = "Mock feed for testing."

        let item1 = RSSFeedItem()
        item1.title = "First Title"
        item1.description = "First description."
        item1.pubDate = Date(timeIntervalSince1970: 1078437600)

        let item2 = RSSFeedItem()
        item2.title = "Second Title"
        item2.description = "Second description."
        item2.pubDate = Date(timeIntervalSinceNow: 1693515600)

        feed.items = [item1, item2]

        return feed
    }()

}
