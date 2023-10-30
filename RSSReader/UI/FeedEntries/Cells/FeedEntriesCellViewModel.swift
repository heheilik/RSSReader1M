//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Internal properties

    let title: String?
    let description: String?
    let date: Date?

    // TODO: add image
    // TODO: add read status

    // MARK: Initialization

    init(title: String?, description: String?, date: Date?) {
        self.title = title
        self.description = description
        self.date = date
        super.init(cellIdentifier: FeedSourceCell.cellIdentifier, delegate: nil)
    }

}
