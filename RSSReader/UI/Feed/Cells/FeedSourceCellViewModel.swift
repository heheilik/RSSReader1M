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

    // MARK: Public properties

    let name: String

    private weak var currentDelegate: FeedSourceCellViewModelDelegate? {
        delegate as? FeedSourceCellViewModelDelegate
    }

    // MARK: Initialization

    init(name: String, delegate: FMCellViewModelDelegate) {
        self.name = name
        super.init(
            cellIdentifier: FeedSourceCell.cellIdentifier,
            delegate: delegate
        )
    }

}

// MARK: - FMSelectableCellModel

extension FeedSourceCellViewModel: FMSelectableCellModel {

    func didSelect() {
        currentDelegate?.didSelect(cellWithUrl: URL(string: "https://www.swift.org/atom.xml")!)
    }

}
