//
//  FeedSourceCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

protocol FeedSourceCellViewModelDelegate: AnyObject {
    func didSelect(cellWithData feedSource: FeedSource)
}

final class FeedSourceCellViewModel: FMCellViewModel {

    // MARK: Internal properties

    let feedSource: FeedSource

    // MARK: Private properties

    private weak var currentDelegate: FeedSourceCellViewModelDelegate? {
        delegate as? FeedSourceCellViewModelDelegate
    }

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
