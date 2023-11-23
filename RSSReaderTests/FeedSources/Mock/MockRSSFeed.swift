//
//  MockRSSFeed.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FeedKit
import Foundation

extension RSSFeed {

    enum FeedsList {
        case rss
        case atom
        case json
        case noFeed

        static let emptyRSSFeed = RSSFeed()
        static let emptyAtomFeed = AtomFeed()
        static let emptyJSONFeed: JSONFeed = {
            let jsonString = """
            {
                "version": "0.0.0",
                "title": "JSON"
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let parser = FeedParser(data: jsonData)

            let result = parser.parse()
            guard
                case let .success(feed) = result,
                case let .json(jsonFeed) = feed
            else {
                fatalError("Feed parsing must succeed.")
            }

            return jsonFeed
        }()

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

        var url: URL {
            switch self {
            case .rss:
                return URL(string: "https://rssFeed.url")!
            case .atom:
                return URL(string: "https://atomFeed.url")!
            case .json:
                return URL(string: "https://jsonFeed.url")!
            case .noFeed:
                return URL(string: "https://noFeed.url")!
            }
        }

        var feed: Feed? {
            switch self {
            case .rss:
                return Feed.rss(FeedsList.emptyRSSFeed)
            case .atom:
                return Feed.atom(FeedsList.emptyAtomFeed)
            case .json:
                return Feed.json(FeedsList.emptyJSONFeed)
            case .noFeed:
                return nil
            }
        }

        init?(fromURL url: URL) {
            switch url.absoluteString {
            case "https://rssFeed.url":
                self = .rss
            case "https://atomFeed.url":
                self = .atom
            case "https://jsonFeed.url":
                self = .json
            case "https://noFeed.url":
                self = .noFeed
            default:
                return nil
            }
        }
    }

}
