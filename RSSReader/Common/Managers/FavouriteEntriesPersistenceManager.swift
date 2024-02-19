//
//  FavouriteEntriesPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import CoreData
import Factory
import Foundation

class FavouriteEntriesPersistenceManager: BasePersistenceManager<ManagedFeedEntry> {

    // MARK: Initialization

    init() {
        super.init(
            predicate: NSPredicate(
                format: "%K == %@",
                argumentArray: [
                    #keyPath(ManagedFeedEntry.isFavourite),
                    true
                ]
            ),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \ManagedFeedEntry.date,
                    ascending: false
                )
            ]
        )
    }
}
