//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Private properties

    private let title: String?
    private let description: String?
    private let date: Date?

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
