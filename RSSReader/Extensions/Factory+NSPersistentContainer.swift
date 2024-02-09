//
//  Factory+NSPersistentContainer.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.02.24.
//

import CoreData
import Factory
import Foundation

extension Container {
    var feedModelPersistentContainer: Factory<NSPersistentContainer> {
        self {
            guard let container = PersistentContainerBuilder.shared.newPersistentContainer(for: .feed) else {
                fatalError("Failed to load persistent store.")
            }
            return container
        }.singleton
    }
}
