//
//  FeedSourceCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedSourceCellViewModel: FMCellViewModel {

    private weak var currentDelegate: FeedSourceCellViewModelDelegate? {
        delegate as? FeedSourceCellViewModelDelegate
    }

    // MARK: Internal properties

    let feedSource: FeedSource

    // MARK: Initialization

    init(
        feedSource: FeedSource,
        delegate: FMCellViewModelDelegate
    ) {
        self.feedSource = feedSource
        super.init(
            cellIdentifier: FeedSourceCell.cellIdentifier,
            delegate: delegate
        )
    }

}

// MARK: - FMSelectableCellModel

extension FeedSourceCellViewModel: FMSelectableCellModel {

    func didSelect() {
        currentDelegate?.didSelect(cellWithData: feedSource)
    }

}
