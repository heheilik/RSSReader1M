//
//  FeedViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation
import FeedKit

class FeedViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    var downloadDelegate: FeedDownloadDelegate?

    // MARK: Private properties

    private var sections: [FMSectionViewModel]

    private var feedService: FeedService

    // MARK: Initialization

    convenience init(
        dataSource: FMDataManager,
        downloadDelegate: FeedDownloadDelegate? = nil
    ) {
        self.init(
            sections: dataSource.sectionViewModels,
            dataSource: dataSource,
            downloadDelegate: downloadDelegate
        )
        for section in sections {
            section.delegate = self
        }
    }

    init(
        sections: [FMSectionViewModel],
        dataSource: FMDataManager,
        downloadDelegate: FeedDownloadDelegate? = nil,
        feedService: FeedService = FeedService()
    ) {
        self.sections = sections
        self.feedService = feedService
        self.downloadDelegate = downloadDelegate
        super.init(dataSource: dataSource)
    }

}

// MARK: - FeedSourcesSectionViewModelDelegate

extension FeedViewModel: FeedSourcesSectionViewModelDelegate {


    func didSelect(cellWithUrl url: URL) {
        downloadDelegate?.downloadStarted()

        feedService.prepareFeed(at: url) { feed in
            var result: Result<RSSFeed, DownloadError>?
            defer {
                guard let result else {
                    fatalError("Result must be set before returning.")
                }
                DispatchQueue.main.async {
                    self.downloadDelegate?.downloadCompleted(result)
                }
            }

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
