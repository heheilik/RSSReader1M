//
//  MOCFeedService.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import FeedKit
import Foundation

class MOCFeedService: FeedService {

    var prepareFeedCalled = false

    override func prepareFeed(at url: URL, completion: @escaping (Feed?) -> Void) {
        prepareFeedCalled = true
        completion(
            FeedsList(fromURL: url)?.feed
        )
    }

}

// MARK: - Static MOC Feeds

extension MOCFeedService {

    enum FeedsList {
        case rss
        case atom
        case json

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

        var url: URL {
            switch self {
            case .rss:
                return URL(string: "https://rssFeed.url")!
            case .atom:
                return URL(string: "https://atomFeed.url")!
            case .json:
                return URL(string: "https://jsonFeed.url")!
            }
        }

        var feed: Feed {
            switch self {
            case .rss:
                return Feed.rss(MOCFeedService.FeedsList.emptyRSSFeed)
            case .atom:
                return Feed.atom(MOCFeedService.FeedsList.emptyAtomFeed)
            case .json:
                return Feed.json(MOCFeedService.FeedsList.emptyJSONFeed)
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
            default:
                return nil
            }
        }
    }

}
