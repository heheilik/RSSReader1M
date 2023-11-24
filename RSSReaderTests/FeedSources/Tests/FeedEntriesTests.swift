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
        guard let mockRSSFeed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full
        )?.rssFeed else {
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

    func testSectionViewModelNoItemsInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .noItems
            ),
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelItemsWithoutDateInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .withoutDate
            ),
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelWithNoImageInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .noImage
            ),
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }
    
    func testSectionViewModelWithNoImageLinkInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .noLink
            ),
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelWithBadImageLinkInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .badLink
            ),
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }
    
    func testSectionViewModelWithEmptyImageLinkInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .emptyLink
            ),
            mustCallPrepareImage: false,
            resultingImage: MockFeedImageService.Constants.errorImage
        )
    }

    func testSectionViewModelWithSeparatedImageLinkInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .separatedLink
            ),
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.correctImage
        )
    }

    func testSectionViewModelWithFullImageLinkInFeed() {
        testSectionViewModel(
            withConfig: FeedConfig(
                feedType: .rss,
                itemConfig: .full,
                imageConfig: .fullLink
            ),
            mustCallPrepareImage: true,
            resultingImage: MockFeedImageService.Constants.correctImage
        )
    }

    // MARK: Private methods

    private func testSectionViewModel(
        withConfig config: FeedConfig,
        mustCallPrepareImage: Bool,
        resultingImage: UIImage
    ) {
        guard let rssFeed = MockFeedFactory.feedForConfig(config)?.rssFeed else {
            fatalError("Can't create mock feed.")
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
