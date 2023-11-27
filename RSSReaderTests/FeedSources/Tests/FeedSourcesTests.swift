//
//  FeedSourcesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import FeedKit
import FMArchitecture
import XCTest
@testable import RSSReader

final class FeedSourcesTests: XCTestCase {

    var viewModel: FeedSourcesViewModel?

    let downloadDelegate = MockDownloadDelegate()
    let feedService = MockFeedService()

    // MARK: Lifecycle

    override func setUp() {
        viewModel = FeedSourcesViewModel(
            context: FeedSourcesContext.mock,
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

    func testViewModelWithRSSFeed() {
        testViewModelWithFeed(
            config: FeedConfig(
                feedType: .rss
            ),
            mustGetError: nil
        )
    }

    func testViewModelWithAtomFeed() {
        testViewModelWithFeed(
            config: FeedConfig(
                feedType: .atom
            ),
            mustGetError: .atomFeedDownloaded
        )
    }

    func testViewModelWithJSONFeed() {
        testViewModelWithFeed(
            config: FeedConfig(
                feedType: .json
            ),
            mustGetError: .jsonFeedDownloaded
        )
    }

    func testViewModelWithNoFeed() {
        testViewModelWithFeed(
            config: FeedConfig(
                feedType: .notExisting
            ),
            mustGetError: .feedNotDownloaded
        )
    }

    func testSectionViewModel() {
        let sectionViewModel = FeedSourcesSectionViewModel(
            context: FeedSourcesContext.mock,
            delegate: viewModel!
        )
        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedSourceCell.self }))

        XCTAssert(sectionViewModel.cellViewModels.count == FeedSourcesContext.mock.data.count)

        for (index, cellViewModel) in sectionViewModel.cellViewModels.enumerated() {
            guard let cellViewModel = cellViewModel as? FeedSourceCellViewModel else {
                XCTFail("CellViewModel type must be FeedSourceCellViewModel.")
                return
            }
            XCTAssert(cellViewModel.feedSource.name == FeedSourcesContext.mock.data[index].name)
            XCTAssert(cellViewModel.feedSource.url == FeedSourcesContext.mock.data[index].url)
        }

        sectionViewModel.didSelect(cellWithData: FeedSourcesContext.mock.data[0])
        XCTAssert(downloadDelegate.didDownloadStart)

        let expectation = XCTestExpectation(description: "Called prepareFeed method.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem {
            XCTAssert(self.feedService.prepareFeedCalled)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    func testCellViewModel() {
        let sectionViewModel = FeedSourcesSectionViewModel(
            context: FeedSourcesContext.mock,
            delegate: viewModel!
        )
        let cellViewModels = sectionViewModel.cellViewModels

        for cellViewModel in cellViewModels {
            guard let cellViewModel = cellViewModel as? FeedSourceCellViewModel else {
                XCTFail("CellViewModel must be of type FeedSourceCellViewModel.")
                return
            }
        }

        guard let cellViewModel = cellViewModels[0] as? FeedSourceCellViewModel else {
            fatalError("This must have been checked earlier.")
        }

        cellViewModel.didSelect()
        XCTAssert(downloadDelegate.didDownloadStart)

        let expectation = XCTestExpectation(description: "Called prepareFeed method.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem {
            XCTAssert(self.feedService.prepareFeedCalled)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.2)
    }

    // MARK: Private methods

    private func testViewModelWithFeed(
        config: FeedConfig,
        mustGetError downloadError: DownloadError?
    ) {
        let downloadCompletedExpectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            if let downloadError {
                guard case let .failure(error) = result else {
                    XCTFail("Must get failure.")
                    return
                }
                XCTAssert(error == downloadError)
                downloadCompletedExpectation.fulfill()
            } else {
                guard case .success = result else {
                    XCTFail("Must succeed.")
                    return
                }
                downloadCompletedExpectation.fulfill()
            }
        }

        guard let viewModel = viewModel else {
            fatalError("viewModel must be instantiated in setUp() method.")
        }

        viewModel.didSelect(cellWithData: FeedSource(
            name: "Test",
            url: MockFeedFactory.urlForConfig(config)
        ))
        XCTAssert(downloadDelegate.didDownloadStart)

        let prepareFeedExpectation = XCTestExpectation(description: "Called prepareFeed method.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem {
            XCTAssert(self.feedService.prepareFeedCalled)
            prepareFeedExpectation.fulfill()
        })
        wait(for: [prepareFeedExpectation, downloadCompletedExpectation], timeout: 0.2)
    }

}
