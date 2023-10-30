//
//  FeedViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

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
            var error: DownloadError? = nil
            defer {
                DispatchQueue.main.async {
                    self.downloadDelegate?.downloadCompleted(withError: error)
                }
            }

            guard let feed else {
                error = .feedNotDownloaded
                return
            }

            switch feed {
            case let .rss(feed):
                print("RSS Feed downloaded.")
                print("Title: \(feed.title ?? "No title.")")
                return

            case .atom(_):
                error = .atomFeedDownloaded
                return
            case .json(_):
                error = .jsonFeedDownloaded
                return
            }
        }
    }

}
