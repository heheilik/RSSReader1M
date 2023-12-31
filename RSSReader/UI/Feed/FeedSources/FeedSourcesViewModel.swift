//
//  FeedSourcesViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation
import FeedKit

class FeedSourcesViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    private(set) var lastClickedFeedName: String = ""

    // MARK: Private properties

    private var sectionViewModels: [FMSectionViewModel] = []

    private var feedService: FeedService
    private weak var downloadDelegate: FeedDownloadDelegate?

    // MARK: Initialization

    init(
        context: FeedSourcesContext,
        dataSource: FMDataManager,
        downloadDelegate: FeedDownloadDelegate,
        feedService: FeedService = FeedService()
    ) {
        self.downloadDelegate = downloadDelegate
        self.feedService = feedService
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
        dataSource.update(with: sectionViewModels)
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedSourcesContext) {
        sectionViewModels = [
            FeedSourcesSectionViewModel(
                context: context,
                delegate: self
            )
        ]
    }

}

// MARK: - FeedSourcesSectionViewModelDelegate

extension FeedSourcesViewModel: FeedSourcesSectionViewModelDelegate {

    func didSelect(cellWithData feedSource: FeedSource) {
        lastClickedFeedName = feedSource.name

        downloadDelegate?.downloadStarted()
        Task {
            var result: Result<RSSFeed, DownloadError>?
            defer {
                guard let result else {
                    fatalError("Result must be set before returning.")
                }
                DispatchQueue.main.async {
                    self.downloadDelegate?.downloadCompleted(result)
                }
            }

            let feed = await feedService.prepareFeed(at: feedSource.url)

            guard let feed else {
                result = .failure(.feedNotDownloaded)
                return
            }

            switch feed {
            case let .rss(feed):
                result = .success(feed)
                return

            case .atom(_):
                result = .failure(.atomFeedDownloaded)
                return
            case .json(_):
                result = .failure(.jsonFeedDownloaded)
                return
            }
        }
    }

}
