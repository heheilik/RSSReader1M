//
//  FavouriteEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import FMArchitecture
import Foundation

class FavouriteEntriesSectionViewModel: FMSectionViewModel {

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntryTableViewCell.self
    ]}

    // MARK: Private properties

    private var persistenceManager: FavouriteEntriesPersistenceManager

    // MARK: Initialization

    init(context: FavouriteEntriesContext) {
        self.persistenceManager = context.persistenceManager
        super.init()
    }
}
