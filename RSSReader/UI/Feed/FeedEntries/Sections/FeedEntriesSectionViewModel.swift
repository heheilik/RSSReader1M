//
//  FeedEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture

class FeedEntriesSectionViewModel: FMSectionViewModel {

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntriesCell.self
    ]}

    // MARK: Initialization

    init(context: FeedEntriesContext) {
        super.init()
        configureCellViewModels(context: context)
    }

    // MARK: Private methods

    private func configureCellViewModels(context: FeedEntriesContext) {
        guard let feedItems = context.rssFeed.items else {
            cellViewModels = []
            return
        }
        cellViewModels = feedItems.map({ item in
            FeedEntriesCellViewModel(
                title: item.title,
                description: item.description,
                date: item.pubDate,
                delegate: self
            )
        })
    }

}
