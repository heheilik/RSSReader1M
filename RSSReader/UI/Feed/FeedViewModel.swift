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

extension FeedViewModel: FeedSourcesSectionViewModelDelegate {

    func didSelect(cellWithUrl url: URL) {
        downloadDelegate?.downloadStarted()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: DispatchWorkItem(block: {
            self.downloadDelegate?.downloadCompleted(didSucceed: false)
        }))
    }

}
