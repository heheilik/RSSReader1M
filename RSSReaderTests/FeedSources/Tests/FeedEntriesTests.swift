//
//  FeedEntriesTests.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FMArchitecture
import XCTest
@testable import RSSReader

final class FeedEntriesTests: XCTestCase {

    private var imageService = MockFeedImageService()

    // MARK: Lifecycle

    override func setUp() {
        imageService = MockFeedImageService()
    }

    // MARK: Tests

    func testViewModel() {
        guard let mockRSSFeed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .noImage
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

    func testCellClickability() {
        guard let rssFeed = MockFeedFactory.feedForConfig(
            feedType: .rss,
            itemConfig: .full,
            imageConfig: .fullLink
        )?.rssFeed else {
            fatalError("Can't create mock feed.")
        }

        let context = FeedEntriesContext(
            feedName: "Test",
            rssFeed: rssFeed
        )

        let viewModel = FeedEntriesViewModel(
            dataSource: FMTableViewDataSource(tableView: nil),
            context: context
        )

        guard let sectionViewModel = viewModel.dataSource.sectionViewModels.first else {
            fatalError("Couldn't get sectionViewModel from pageViewModel.")
        }

        guard
            let cellViewModel = sectionViewModel.cellViewModels.randomElement(),
            let cellViewModel = cellViewModel as? FeedEntriesCellViewModel
        else {
            fatalError("Couldn't retrieve cellViewModel from sectionViewModel.")
        }

        let expectation = XCTestExpectation(description: "Read status changes in cell.")
        var firstTime = true
        let cancellable = cellViewModel.$isRead.sink { isRead in
            guard !firstTime else {
                XCTAssertFalse(isRead)
                firstTime = false
                return
            }
            XCTAssertTrue(isRead)
            expectation.fulfill()
        }
        cellViewModel.didSelect()

        wait(for: [expectation], timeout: 1.0)
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

        let expectation = XCTestExpectation(description: "cellViewModel images are updated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem {
            XCTAssert(self.imageService.calledPrepareImage == mustCallPrepareImage)

            XCTAssert(sectionViewModel.image == resultingImage)
            for cellViewModel in sectionViewModel.cellViewModels {
                guard let cellViewModel = cellViewModel as? FeedEntriesCellViewModel else {
                    continue
                }
                XCTAssert(sectionViewModel.image == cellViewModel.image)
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
    }

}
