//
//  FeedSourceCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

protocol FeedSourceCellViewModelDelegate: AnyObject {

    func didSelect(cellWithUrl url: URL)

}

class FeedSourceCellViewModel: FMCellViewModel {

    // MARK: Internal properties

    let name: String
    let url: URL

    private weak var currentDelegate: FeedSourceCellViewModelDelegate? {
        delegate as? FeedSourceCellViewModelDelegate
    }

    // MARK: Initialization

    init(
        name: String,
        url: URL,
        delegate: FMCellViewModelDelegate
    ) {
        self.name = name
        self.url = url
        super.init(
            cellIdentifier: FeedSourceCell.cellIdentifier,
            delegate: delegate
        )
    }

}

// MARK: - FMSelectableCellModel

extension FeedSourceCellViewModel: FMSelectableCellModel {

    func didSelect() {
        currentDelegate?.didSelect(cellWithUrl: url)
    }

}
