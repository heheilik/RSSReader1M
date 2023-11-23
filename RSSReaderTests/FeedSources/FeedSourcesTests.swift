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
        viewModel = FeedSourcesViewModel(
            context: FeedSourcesContext.moc,
            dataSource: FMTableViewDataSource(tableView: nil),
            downloadDelegate: downloadDelegate,
            feedService: feedService
        )
    }

    override func tearDown() {
        viewModel = nil

        downloadDelegate.didDownloadStart = false
        downloadDelegate.downloadCompletedCallback = nil

        feedService.prepareFeedCalled = false
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

    func testViewModelWithRSSFeed() {
        let expectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            guard case .success = result else {
                XCTAssert(false)
                return
            }

            expectation.fulfill()
        }

        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        viewModel.didSelect(cellWithData: FeedSource(
            name: "RSS",
            url: MOCFeedService.FeedsList.rss.url
        ))

        wait(for: [expectation], timeout: 1.0)
    }

    func testViewModelWithAtomFeed() {
        let expectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            guard case let .failure(error) = result else {
                XCTAssert(false)
                return
            }

            XCTAssert(error == .atomFeedDownloaded)
            expectation.fulfill()
        }

        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        viewModel.didSelect(cellWithData: FeedSource(
            name: "Atom",
            url: MOCFeedService.FeedsList.atom.url
        ))

        wait(for: [expectation], timeout: 1.0)
    }

    func testViewModelWithJSONFeed() {
        let expectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            guard case let .failure(error) = result else {
                XCTAssert(false)
                return
            }

            XCTAssert(error == .jsonFeedDownloaded)
            expectation.fulfill()
        }

        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        viewModel.didSelect(cellWithData: FeedSource(
            name: "JSON",
            url: MOCFeedService.FeedsList.json.url
        ))

        wait(for: [expectation], timeout: 1.0)
    }

}
