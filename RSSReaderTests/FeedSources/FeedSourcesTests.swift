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
                XCTAssert(false)
                return
            }
            XCTAssert(cellViewModel.feedSource.name == FeedSourcesContext.moc.data[index].name)
            XCTAssert(cellViewModel.feedSource.url == FeedSourcesContext.moc.data[index].url)
        }
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

        XCTAssert(feedService.prepareFeedCalled)
        XCTAssert(downloadDelegate.didDownloadStart)

        wait(for: [expectation], timeout: 1.0)
    }

}