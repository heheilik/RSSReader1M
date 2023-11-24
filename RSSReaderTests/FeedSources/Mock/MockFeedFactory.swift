//
//  MockFeedFactory.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 24.11.23.
//

import FeedKit
import Foundation

struct FeedConfig {
    let feedType: MockFeedFactory.FeedType
    let itemConfig: MockFeedFactory.ItemConfig
    let imageConfig: MockFeedFactory.ImageConfig

    init(
        feedType: MockFeedFactory.FeedType = .notExisting,
        itemConfig: MockFeedFactory.ItemConfig = .noItems,
        imageConfig: MockFeedFactory.ImageConfig = .noImage
    ) {
        self.feedType = feedType
        self.itemConfig = itemConfig
        self.imageConfig = imageConfig
    }
}

final class MockFeedFactory {

    enum ConfigFieldsNames: String {
        case feedType
        case itemConfig
        case imageConfig
    }

    enum FeedType: String {
        case notExisting
        case rss
        case atom
        case json
    }

    enum ItemConfig: String {
        case noItems
        case withoutDate
        case full
    }

    // TODO: Add noImage
    enum ImageConfig: String {
        case noImage
        case noLink
        case emptyLink
        case badLink
        case separatedLink
        case fullLink
    }

    private static let dateConstants: [Date] = [
        Date(timeIntervalSince1970: 1078437600),  // 05.03.2004 00:00:00 GMT+3
        Date(timeIntervalSince1970: 1693515600),  // 01.09.2023 00:00:00 GMT+3
    ]

    // MARK: Public methods

    public static func urlForConfig(_ config: FeedConfig) -> URL {
        urlForConfig(
            feedType: config.feedType,
            itemConfig: config.itemConfig,
            imageConfig: config.imageConfig
        )
    }

    public static func urlForConfig(
        feedType: FeedType = .notExisting,
        itemConfig: ItemConfig = .noItems,
        imageConfig: ImageConfig = .noImage
    ) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(feedType.rawValue).feed"

        components.queryItems = [
            URLQueryItem(name: ConfigFieldsNames.feedType.rawValue, value: feedType.rawValue),
            URLQueryItem(name: ConfigFieldsNames.itemConfig.rawValue, value: itemConfig.rawValue),
            URLQueryItem(name: ConfigFieldsNames.imageConfig.rawValue, value: imageConfig.rawValue),
        ]

        guard let url = components.url else {
            fatalError("Error constructing URL.")
        }
        return url
    }

    public static func configForURL(_ url: URL) -> FeedConfig? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard let items = components?.queryItems else {
            return nil
        }

        var feedType: FeedType?
        var itemConfig: ItemConfig?
        var imageConfig: ImageConfig?

        for item in items {
            guard let itemType = ConfigFieldsNames(rawValue: item.name) else {
                return nil
            }

            switch itemType {
            case .feedType:
                feedType = FeedType(rawValue: item.value ?? "")
            case .itemConfig:
                itemConfig = ItemConfig(rawValue: item.value ?? "")
            case .imageConfig:
                imageConfig = ImageConfig(rawValue: item.value ?? "")
            }
        }

        guard let feedType, let itemConfig, let imageConfig else {
            return nil
        }
        return FeedConfig(
            feedType: feedType,
            itemConfig: itemConfig,
            imageConfig: imageConfig
        )
    }

    public static func feedForConfig(_ config: FeedConfig) -> Feed? {
        feedForConfig(
            feedType: config.feedType,
            itemConfig: config.itemConfig,
            imageConfig: config.imageConfig
        )
    }

    public static func feedForConfig(
        feedType: FeedType = .notExisting,
        itemConfig: ItemConfig = .noItems,
        imageConfig: ImageConfig = .noImage
    ) -> Feed? {
        var feed: Feed?

        feed = createFeed(ofType: feedType)
        feed = configureItems(for: feed, with: itemConfig)
        feed = configureImage(for: feed, with: imageConfig)

        return feed
    }

    public static func feedForUrl(_ url: URL) -> Feed? {
        guard let config = configForURL(url) else {
            return nil
        }
        return feedForConfig(config)
    }

    // MARK: Private methods

    private static func createFeed(ofType type: FeedType) -> Feed? {
        switch type {
        case .notExisting:
            return nil
        case .rss:
            return Feed.rss(RSSFeed())
        case .atom:
            return Feed.atom(AtomFeed())
        case .json:
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

            return Feed.json(jsonFeed)
        }
    }

    private static func configureItems(for feed: Feed?, with config: ItemConfig) -> Feed? {
        switch config {
        case .noItems:
            guard let rssFeed = feed?.rssFeed else {
                return feed
            }

            rssFeed.title = "Test"
            rssFeed.description = "Mock feed for testing."
            rssFeed.items = nil

            return Feed.rss(rssFeed)

        case .withoutDate:
            guard let rssFeed = configureItems(for: feed, with: .noItems)?.rssFeed else {
                return feed
            }

            rssFeed.items = {
                let item1 = RSSFeedItem()
                item1.title = "First Title"
                item1.description = "First description."

                let item2 = RSSFeedItem()
                item2.title = "Second Title"
                item2.description = "Second description."

                return [item1, item2]
            }()

            return Feed.rss(rssFeed)

        case .full:
            guard let rssFeed = configureItems(for: feed, with: .withoutDate)?.rssFeed else {
                return feed
            }

            rssFeed.items?.forEach({ item in
                item.pubDate = dateConstants.randomElement()
            })

            return Feed.rss(rssFeed)
        }
    }

    private static func configureImage(for feed: Feed?, with config: ImageConfig) -> Feed? {
        guard let rssFeed = feed?.rssFeed else {
            return feed
        }

        switch config {
        case .noImage:
            rssFeed.image = nil

        case .noLink:
            rssFeed.image = {
                let image = RSSFeedImage()
                return image
            }()

        case .emptyLink:
            rssFeed.link = ""
            rssFeed.image = {
                let image = RSSFeedImage()
                image.url = ""
                return image
            }()

        case .badLink:
            rssFeed.link = "https://someBadLink.url"
            rssFeed.image = {
                let image = RSSFeedImage()
                image.url = "https://badButCorrect.url"
                return image
            }()

        case .separatedLink:
            rssFeed.link = MockFeedImageService.Constants.separatedImageFeedURL.absoluteString
            rssFeed.image = {
                let image = RSSFeedImage()
                image.url = MockFeedImageService.Constants.separatedImageURL.absoluteString
                return image
            }()

        case .fullLink:
            rssFeed.image = {
                let image = RSSFeedImage()
                image.url = MockFeedImageService.Constants.fullURL.absoluteString
                return image
            }()

        }

        return Feed.rss(rssFeed)
    }

}
