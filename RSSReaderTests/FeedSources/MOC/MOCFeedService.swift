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

        static let emptyRSSFeed = RSSFeed()
        static let emptyAtomFeed = AtomFeed()

        var url: URL {
            switch self {
            case .rss:
                return URL(string: "https://rssFeed.url")!
            case .atom:
                return URL(string: "https://atomFeed.url")!
            }
        }

        var feed: Feed {
            switch self {
            case .rss:
                return Feed.rss(MOCFeedService.FeedsList.emptyRSSFeed)
            case .atom:
                return Feed.atom(MOCFeedService.FeedsList.emptyAtomFeed)
            }
        }

        init?(fromURL url: URL) {
            switch url.absoluteString {
            case "https://rssFeed.url":
                self = .rss
            case "https://atomFeed.url":
                self = .atom
            default:
                return nil
            }
        }
    }

}
