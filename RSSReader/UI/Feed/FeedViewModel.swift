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

    convenience override init(dataSource: FMDataManager) {
        self.init(
            sections: dataSource.sectionViewModels,
            dataSource: dataSource
        )
    }

    init(
        sections: [FMSectionViewModel],
        dataSource: FMDataManager,
        feedService: FeedService = FeedService()
    ) {
        self.sections = sections
        self.feedService = feedService
        super.init(dataSource: dataSource)
    }

}
