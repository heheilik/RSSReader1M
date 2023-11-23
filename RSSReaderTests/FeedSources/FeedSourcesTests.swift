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

    // MARK: Lifecycle

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

    // MARK: Tests

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
        testViewModelWithFeed(
            ofType: .rss,
            mustGetError: nil
        )
    }

    func testViewModelWithAtomFeed() {
        testViewModelWithFeed(
            ofType: .atom,
            mustGetError: .atomFeedDownloaded
        )
    }

    func testViewModelWithJSONFeed() {
        testViewModelWithFeed(
            ofType: .json,
            mustGetError: .jsonFeedDownloaded
        )
    }

    // MARK: Private methods

    private func testViewModelWithFeed(
        ofType type: MOCFeedService.FeedsList,
        mustGetError downloadError: DownloadError?
    ) {
        let expectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            if let downloadError {
                guard case let .failure(error) = result else {
                    XCTAssert(false)
                    return
                }
                XCTAssert(error == downloadError)
                expectation.fulfill()
            } else {
                guard case .success = result else {
                    XCTAssert(false)
                    return
                }
                expectation.fulfill()
            }
        }

        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        viewModel.didSelect(cellWithData: FeedSource(
            name: "Test",
            url: type.url
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }

}
