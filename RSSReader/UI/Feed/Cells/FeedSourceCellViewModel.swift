//
//  FeedSourceCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedSourceCellViewModel: FMCellViewModel {

    // MARK: Public properties

    let name: String

    // MARK: Initialization

    init(name: String) {
        self.name = name
        super.init(
            cellIdentifier: FeedSourceCell.cellIdentifier,
            delegate: nil
        )
    }

}

extension FeedSourceCellViewModel: FMSelectableCellModel {

    func didSelect() {
        print("Selected (\(name)).")
    }

}
