//
//  PersistentContainerBuilder.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 9.02.24.
//

import CoreData
import Foundation

final class PersistentContainerBuilder {

    // MARK: Constants

    enum ModelName: String {
        case feed = "FeedModel"
    }

    // MARK: Internal properties

    static let shared = PersistentContainerBuilder()

    // MARK: Initialization

    private init() {}

    // MARK: Internal methods

    func newPersistentContainer(for modelName: ModelName) -> NSPersistentContainer? {
        let persistentContainer = NSPersistentContainer(name: modelName.rawValue)

        guard let databasePath = databasePath(for: modelName) else {
            return nil
        }
        let storeDescription = persistentStoreDescription(for: databasePath)
        addStore(to: persistentContainer, using: storeDescription)

        return persistentContainer
    }

    // MARK: Private methods

    private func databasePath(for modelName: ModelName) -> URL? {
        guard
            let applicationSupportURL = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ),
            let databaseURL = URL(
                string: "\(ModelName.feed.rawValue).sqlite",
                relativeTo: applicationSupportURL
            )
        else {
            return nil
        }
        return databaseURL
    }

    private func persistentStoreDescription(for databasePath: URL) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: databasePath)
        description.setOption(true as NSObject, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSObject, forKey: NSInferMappingModelAutomaticallyOption)
        return description
    }

    private func addStore(
        to persistentContainer: NSPersistentContainer,
        using description: NSPersistentStoreDescription
    ) {
        persistentContainer.persistentStoreCoordinator.addPersistentStore(with: description) { description, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
}
