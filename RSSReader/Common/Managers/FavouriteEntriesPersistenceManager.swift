//
//  FavouriteEntriesPersistenceManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import CoreData
import Factory
import Foundation

final class FavouriteEntriesPersistenceManager: BasePersistenceManager<ManagedFeedEntry> {

    // MARK: Initialization

    init() {
        super.init(
            persistentContainer: Container.shared.feedModelPersistentContainer(),
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
