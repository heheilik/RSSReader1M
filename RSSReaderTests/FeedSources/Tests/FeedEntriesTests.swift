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

    var context: FeedEntriesContext = FeedEntriesContext(
        feedName: "Test",
        rssFeed: MockFeeds.mockRSSFullImageLink.feed!.rssFeed!
    )

    var imageService = MockFeedImageService()

    // MARK: Lifecycle

    override func setUp() {
        guard let mockRSSFeed = MockFeeds.mockRSSFullImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: mockRSSFeed
        )
        imageService = MockFeedImageService()
        viewModel = FeedEntriesViewModel(
            dataSource: FMTableViewDataSource(tableView: nil),
            context: context
        )
    }

    override func tearDown() {
        viewModel = nil
    }

    // MARK: Tests

    func testViewModel() {
        guard let viewModel else {
            fatalError("ViewModel must be instantiated in setUp.")
        }

        let sectionViewModels = viewModel.dataSource.sectionViewModels
        XCTAssert(sectionViewModels.count == 1)

        guard let sectionViewModel = sectionViewModels.first else {
            fatalError("This array must have been checked earlier.")
        }
    }

    func testSectionViewModelWithNoImageLinkInFeed() {
        guard let feed = MockFeeds.mockRSSNoImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: feed
        )

        let sectionViewModel = FeedEntriesSectionViewModel(
            context: context,
            feedImageService: imageService
        )

        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedEntriesCell.self }))
        XCTAssertFalse(imageService.calledPrepareImage)
        XCTAssert(sectionViewModel.image == MockFeedImageService.Constants.errorImage)
    }

    func testSectionViewModelWithBadImageLinkInFeed() {
        guard let feed = MockFeeds.mockRSSBadImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: feed
        )

        let sectionViewModel = FeedEntriesSectionViewModel(
            context: context,
            feedImageService: imageService
        )

        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedEntriesCell.self }))
        XCTAssert(imageService.calledPrepareImage)
        XCTAssert(sectionViewModel.image == MockFeedImageService.Constants.errorImage)
    }

    func testSectionViewModelWithSeparatedImageLinkInFeed() {
        guard let feed = MockFeeds.mockRSSSeparatedImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: feed
        )

        let sectionViewModel = FeedEntriesSectionViewModel(
            context: context,
            feedImageService: imageService
        )

        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedEntriesCell.self }))
        XCTAssert(imageService.calledPrepareImage)
        XCTAssert(sectionViewModel.image == MockFeedImageService.Constants.correctImage)
    }

    func testSectionViewModelWithFullImageLinkInFeed() {
        guard let feed = MockFeeds.mockRSSFullImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: feed
        )

        let sectionViewModel = FeedEntriesSectionViewModel(
            context: context,
            feedImageService: imageService
        )

        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedEntriesCell.self }))
        XCTAssert(imageService.calledPrepareImage)
        XCTAssert(sectionViewModel.image == MockFeedImageService.Constants.correctImage)
    }


}
