//
//  UnseenEntriesAmountHeaderViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 5.02.24.
//

import FMArchitecture
import Foundation

class UnseenEntriesAmountHeaderViewModel: FMHeaderFooterViewModel {

    // MARK: Internal properties

    var text: String

    // MARK: Initialization

    init(text: String) {
        self.text = text
        super.init(
            cellIdentifier: UnseenEntriesAmountTableViewHeader.cellIdentifier,
            delegate: nil
        )
    }
}
