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
    case mockRSSNoImageLink
    case mockRSSBadImageLink
    case mockRSSEmptyImageLink
    case mockRSSSeparatedImageLink
    case mockRSSFullImageLink
    case emptyAtom
    case emptyJSON
    
    // MARK: Internal properties

    var url: URL {
        switch self {
        case .noFeed:
            return URL(string: "https://noFeed/")!
        case .emptyRSS:
            return URL(string: "https://emptyRSSFeed/")!
        case .mockRSSNoImageLink:
            return URL(string: "https://noImageRSSFeed/")!
        case .mockRSSBadImageLink:
            return URL(string: "https://badImageRSSFeed/")!
        case .mockRSSEmptyImageLink:
            return URL(string: "https://emptyImageLinkRSSFeed/")!
        case .mockRSSSeparatedImageLink:
            return URL(string: "https://separatedImageLinkRSSFeed/")!
        case .mockRSSFullImageLink:
            return URL(string: "https://fullImageLinkRSSFeed/")!
        case .emptyAtom:
            return URL(string: "https://emptyAtomFeed/")!
        case .emptyJSON:
            return URL(string: "https://emptyJSONFeed/")!
        }
    }

    var feed: Feed? {
        switch self {
        case .noFeed:
            return nil
        case .emptyRSS:
            return Feed.rss(Self.emptyRSSFeed())
        case .mockRSSNoImageLink:
            return Feed.rss(Self.noImageLinkRSSFeed())
        case .mockRSSBadImageLink:
            return Feed.rss(Self.badImageLinkRSSFeed())
        case .mockRSSEmptyImageLink:
            return Feed.rss(Self.emptyImageLinkRSSFeed())
        case .mockRSSSeparatedImageLink:
            return Feed.rss(Self.separatedImageLinkRSSFeed())
        case .mockRSSFullImageLink:
            return Feed.rss(Self.fullImageLinkRSSFeed())
        case .emptyAtom:
            return Feed.atom(Self.emptyAtomFeed())
        case .emptyJSON:
            return Feed.json(Self.emptyJSONFeed())
        }
    }

    // MARK: Private properties

    private static let emptyRSSFeed = {
        return RSSFeed()
    }

    private static let noImageLinkRSSFeed = {
        let feed = RSSFeed()

        feed.title = "Test"
        feed.description = "Mock feed for testing."

        feed.items = {
            let item1 = RSSFeedItem()
            item1.title = "First Title"
            item1.description = "First description."
            item1.pubDate = Date(timeIntervalSince1970: 1078437600)  // 05.03.2004 00:00:00 GMT+3

            let item2 = RSSFeedItem()
            item2.title = "Second Title"
            item2.description = "Second description."
            item2.pubDate = Date(timeIntervalSinceNow: 1693515600)  // 01.09.2023 00:00:00 GMT+3

            return [item1, item2]
        }()

        return feed
    }

    private static let badImageLinkRSSFeed = {
        let feed = Self.noImageLinkRSSFeed()

        feed.link = Self.mockRSSBadImageLink.url.absoluteString
        feed.image = {
            let image = RSSFeedImage()
            image.url = "https://reallyBad.url"
            return image
        }()

        return feed
    }
    
    private static let emptyImageLinkRSSFeed = {
        let feed = Self.noImageLinkRSSFeed()

        feed.link = ""
        feed.image = {
            let image = RSSFeedImage()
            image.url = ""
            return image
        }()

        return feed
    }

    private static let separatedImageLinkRSSFeed = {
        let feed = Self.noImageLinkRSSFeed()

        feed.link = MockFeedImageService.Constants.separatedImageFeedURL.absoluteString
        feed.image = {
            let image = RSSFeedImage()
            image.url = MockFeedImageService.Constants.separatedImageURL.absoluteString
            return image
        }()

        return feed
    }

    private static let fullImageLinkRSSFeed = {
        let feed = Self.noImageLinkRSSFeed()

        feed.link = MockFeeds.mockRSSFullImageLink.url.absoluteString
        feed.image = {
            let image = RSSFeedImage()
            image.url = MockFeedImageService.Constants.fullURL.absoluteString
            return image
        }()

        return feed
    }

    private static let emptyAtomFeed = {
        return AtomFeed()
    }

    private static let emptyJSONFeed = {
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
    }

    // MARK: Initialization

    init?(fromURL url: URL) {
        for type in Self.allCases {
            if url == type.url {
                self = type
                return
            }
        }
        return nil
    }

}
