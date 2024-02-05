//
//  Factory+NSPersistentContainer.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.02.24.
//

import CoreData
import Factory
import Foundation

private enum ModelNames {
    static let feed = "FeedModel"
}

extension Container {
    var feedModelPersistentContainer: Factory<NSPersistentContainer> {
        self {
            let persistentContainer = NSPersistentContainer(name: ModelNames.feed)
            persistentContainer.loadPersistentStores { _, error in
                if let error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return persistentContainer
        }.singleton
    }
}