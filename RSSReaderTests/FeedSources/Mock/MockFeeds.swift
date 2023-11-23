//
//  MockFeeds.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FeedKit
import Foundation

enum MockFeeds: CaseIterable, Hashable {
    
    case noFeed
    case emptyRSS
    case mockRSS
    case emptyAtom
    case emptyJSON

    // MARK: Internal properties

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

    static let mockRSSFeed: RSSFeed = {
        let feed = RSSFeed()

        feed.title = "Test"
        feed.description = "Mock feed for testing."

        let item1 = RSSFeedItem()
        item1.title = "First Title"
        item1.description = "First description."
        item1.pubDate = Date(timeIntervalSince1970: 1078437600)  // 05.03.2004 00:00:00 GMT+3

        let item2 = RSSFeedItem()
        item2.title = "Second Title"
        item2.description = "Second description."
        item2.pubDate = Date(timeIntervalSinceNow: 1693515600)  // 01.09.2023 00:00:00 GMT+3

        feed.items = [item1, item2]

        return feed
    }()

    var url: URL {
        return URL(string: Self.urlStringFor(type: self))!
    }

    var feed: Feed? {
        switch self {
        case .noFeed:
            return nil
        case .emptyRSS:
            return Feed.rss(Self.emptyRSSFeed)
        case .mockRSS:
            return Feed.rss(Self.mockRSSFeed)
        case .emptyAtom:
            return Feed.atom(Self.emptyAtomFeed)
        case .emptyJSON:
            return Feed.json(Self.emptyJSONFeed)
        }
    }

    // MARK: Initialization

    init?(fromURL url: URL) {
        for type in Self.allCases {
            if url.absoluteString == Self.urlStringFor(type: type) {
                self = type
                return
            }
        }
        return nil
    }

    // MARK: Private methods

    private static func urlStringFor(type: Self) -> String {
        switch type {
        case .noFeed:
            return "https://noFeed.url"
        case .emptyRSS:
            return "https://emptyRSSFeed.url"
        case .mockRSS:
            return "https://mockRSSFeed.url"
        case .emptyAtom:
            return "https://emptyAtomFeed.url"
        case .emptyJSON:
            return "https://emptyJSONFeed.url"
        }
    }

}
