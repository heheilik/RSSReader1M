//
//  MockFeedFactoryTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 24.11.23.
//

import Foundation
import XCTest
@testable import RSSReader

class MockFeedFactoryTests: XCTestCase {

    func testNotExistingFeed() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig())
        XCTAssertNil(feed)
    }

    func testAtomFeed() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .atom))
        XCTAssertNotNil(feed?.atomFeed)
    }

    func testJSONFeed() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .json))
        XCTAssertNotNil(feed?.jsonFeed)
    }

    func testRSSFeed() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .rss))
        XCTAssertNotNil(feed?.rssFeed)
    }

    func testRSSFeedNoItems() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .rss, itemConfig: .noItems))
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        XCTAssert(rssFeed.items == nil)
    }

    func testRSSFeedWithoutDateItems() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .rss, itemConfig: .withoutDate))
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }

        items.forEach { item in
            XCTAssertNil(item.pubDate)
        }
    }

    func testRSSFeedFullItems() {
        let feed = MockFeedFactory.feedForConfig(FeedConfig(feedType: .rss, itemConfig: .full))
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }

        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }
    }

    func testRSSFeedFullItemsNoImage() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .noImage
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssertNil(rssFeed.link)
        XCTAssertNil(rssFeed.image)
    }

    func testRSSFeedFullItemsNoImageLink() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .noLink
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssertNil(rssFeed.link)
        guard let image = rssFeed.image else {
            XCTFail()
            return
        }

        XCTAssertNil(image.url)
    }

    func testRSSFeedFullItemsEmptyImageLink() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .emptyLink
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssert(rssFeed.link == "")
        guard let image = rssFeed.image else {
            XCTFail()
            return
        }
        XCTAssert(image.url == "")
    }

    func testRSSFeedFullItemsBadImageLink() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .badLink
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssertNotNil(rssFeed.link)
        XCTAssert(rssFeed.link != "")
        guard let image = rssFeed.image else {
            XCTFail()
            return
        }
        XCTAssertNotNil(image.url)
        XCTAssert(image.url != "")
    }

    func testRSSFeedFullItemsSeparateImageLink() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .separatedLink
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssert(rssFeed.link == MockFeedImageService.Constants.separatedImageFeedURL.absoluteString)
        guard let image = rssFeed.image else {
            XCTFail()
            return
        }
        XCTAssert(image.url == MockFeedImageService.Constants.separatedImageURL.absoluteString)
    }

    func testRSSFeedFullItemsFullImageLink() {
        let feed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .fullLink
        )
        guard let rssFeed = feed?.rssFeed else {
            XCTFail()
            return
        }

        guard let items = rssFeed.items else {
            XCTFail()
            return
        }
        items.forEach { item in
            XCTAssertNotNil(item.pubDate)
        }

        XCTAssertNil(rssFeed.link)
        XCTAssert(rssFeed.link != "")
        guard let image = rssFeed.image else {
            XCTFail()
            return
        }
        XCTAssert(image.url == MockFeedImageService.Constants.fullURL.absoluteString)
    }

}
