//
//  FeedEntriesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FMArchitecture
import XCTest

class FeedEntriesTests: XCTestCase {

    var viewModel: FeedEntriesViewModel?

    // MARK: Lifecycle

    override func setUp() {
        guard let mockRSSFeed = MockFeeds.mockRSS.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        viewModel = FeedEntriesViewModel(
            dataSource: FMTableViewDataSource(tableView: nil),
            context: FeedEntriesContext(
                feedName: "Test",
                rssFeed: mockRSSFeed
            )
        )
    }

    override func tearDown() {
        viewModel = nil
    }

    // MARK: Tests

}
