//
//  FeedEntriesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FMArchitecture
import XCTest

class FeedEntriesTests: XCTestCase {

    private var imageService = MockFeedImageService()

    // MARK: Lifecycle

    override func setUp() {
        imageService = MockFeedImageService()
    }

    // MARK: Tests

    func testViewModel() {
        guard let mockRSSFeed = MockFeeds.mockRSSFullImageLink.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        let context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: mockRSSFeed
        )
        let viewModel = FeedEntriesViewModel(
            dataSource: FMTableViewDataSource(tableView: nil),
            context: context
        )

        let sectionViewModels = viewModel.dataSource.sectionViewModels
        XCTAssert(sectionViewModels.count == 1)

        guard let sectionViewModel = sectionViewModels.first else {
            fatalError("This array must have been checked earlier.")
        }
        XCTAssert(sectionViewModel.registeredCellTypes.contains(where: { $0 == FeedEntriesCell.self }))
    }

    func testSectionViewModelWithNoImageLinkInFeed() {
        testSectionViewModel(
            with: .mockRSSNoImageLink,
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelWithBadImageLinkInFeed() {
        testSectionViewModel(
            with: .mockRSSBadImageLink,
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelWithSeparatedImageLinkInFeed() {
        testSectionViewModel(
            with: .mockRSSSeparatedImageLink,
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.correctImage
        )
    }

    func testSectionViewModelWithFullImageLinkInFeed() {
        testSectionViewModel(
            with: .mockRSSFullImageLink,
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.correctImage
        )
    }

    // MARK: Private methods

    private func testSectionViewModel(
        with feed: MockFeeds,
        mustCallPrepareImage: Bool,
        resultingImage: UIImage
    ) {
        guard let rssFeed = feed.feed?.rssFeed else {
            fatalError("Can't get feed from MockFeeds enum.")
        }
        let context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: rssFeed
        )

        let sectionViewModel = FeedEntriesSectionViewModel(
            context: context,
            feedImageService: imageService
        )

        XCTAssert(imageService.calledPrepareImage == mustCallPrepareImage)
        XCTAssert(sectionViewModel.image == resultingImage)
    }

}
