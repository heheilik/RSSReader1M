//
//  UnreadEntriesAmountHeaderViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 5.02.24.
//

import FMArchitecture
import Foundation

final class UnreadEntriesAmountHeaderViewModel: FMHeaderFooterViewModel {

    // MARK: Internal properties

    var unreadEntriesCount: Int {
        didSet {
            view?.fill(viewModel: self)
        }
    }

    var text: String {
        "\(unreadEntriesCount) new entries."
    }

    // MARK: Initialization

    init(unreadEntriesCount: Int) {
        self.unreadEntriesCount = unreadEntriesCount
        super.init(
            cellIdentifier: UnreadEntriesAmountTableViewHeader.cellIdentifier,
            delegate: nil
        )
    }
}
