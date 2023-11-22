//
//  FeedSourcesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

// TODO: Cover FeedSourceCellViewModel
// TODO: Cover FeedSourcesSectionViewModel

import FMArchitecture
import XCTest

final class FeedSourcesTests: XCTestCase {

    var viewModel: FeedSourcesViewModel?

    let downloadDelegate = MOCDownloadDelegate()
    let feedService = MOCFeedService()

    override func setUp() {
        // reseting variables
        downloadDelegate.didDownloadStart = false
        feedService.prepareFeedCalled = false

        viewModel = FeedSourcesViewModel(
            context: FeedSourcesContext.moc,
            dataSource: FMTableViewDataSource(tableView: nil),
            downloadDelegate: downloadDelegate,
            feedService: feedService
        )
    }

    override func tearDown() {
        viewModel = nil
    }

    func testViewModel() {
        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        // lastClickedFeedName must be empty at the beginning
        XCTAssert(viewModel.lastClickedFeedName.isEmpty)

        viewModel.didSelect(cellWithData: FeedSourcesContext.moc.data[0])

        XCTAssert(feedService.prepareFeedCalled)
        XCTAssert(downloadDelegate.didDownloadStart)
    }

}
