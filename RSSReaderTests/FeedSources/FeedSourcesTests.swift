//
//  FeedSourcesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import FMArchitecture
import XCTest

final class FeedSourcesTests: XCTestCase {

    var viewModel: FeedSourcesViewModel?

    let downloadDelegate = MockDownloadDelegate()
    let feedService = MockFeedService()

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

    func testViewModelWithNoFeed() {
        testViewModelWithFeed(
            ofType: .noFeed,
            mustGetError: .feedNotDownloaded
        )
    }

    func testSectionViewModel() {
        let sectionViewModel = FeedSourcesSectionViewModel(
            context: FeedSourcesContext.moc,
            delegate: viewModel!
        )
        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedSourceCell.self }))

        XCTAssert(sectionViewModel.cellViewModels.count == FeedSourcesContext.moc.data.count)

        for (index, cellViewModel) in sectionViewModel.cellViewModels.enumerated() {
            guard let cellViewModel = cellViewModel as? FeedSourceCellViewModel else {
                XCTFail("CellViewModel type must be FeedSourceCellViewModel.")
                return
            }
            XCTAssert(cellViewModel.feedSource.name == FeedSourcesContext.moc.data[index].name)
            XCTAssert(cellViewModel.feedSource.url == FeedSourcesContext.moc.data[index].url)
        }

        sectionViewModel.didSelect(cellWithData: FeedSourcesContext.moc.data[0])
        XCTAssert(feedService.prepareFeedCalled)
        XCTAssert(downloadDelegate.didDownloadStart)
    }

    func testCellViewModel() {
        let sectionViewModel = FeedSourcesSectionViewModel(
            context: FeedSourcesContext.moc,
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
        XCTAssert(feedService.prepareFeedCalled)
        XCTAssert(downloadDelegate.didDownloadStart)
    }

    // MARK: Private methods

    private func testViewModelWithFeed(
        ofType type: MockFeedService.FeedsList,
        mustGetError downloadError: DownloadError?
    ) {
        let expectation = XCTestExpectation(description: "Call downloadCompleted() method.")
        downloadDelegate.downloadCompletedCallback = { result in
            if let downloadError {
                guard case let .failure(error) = result else {
                    XCTFail("Must get failure.")
                    return
                }
                XCTAssert(error == downloadError)
                expectation.fulfill()
            } else {
                guard case .success = result else {
                    XCTFail("Must succeed.")
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

        XCTAssert(feedService.prepareFeedCalled)
        XCTAssert(downloadDelegate.didDownloadStart)

        wait(for: [expectation], timeout: 1.0)
    }

}
