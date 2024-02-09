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

            // getting path to database
            guard
                let applicationSupportURL = try? FileManager.default.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                ),
                let databaseURL = URL(
                    string: "\(ModelNames.feed).sqlite",
                    relativeTo: applicationSupportURL
                )
            else {
                fatalError("Failed to get path to database.")
            }

            // creating description
            let description = NSPersistentStoreDescription(url: databaseURL)
            description.setOption(true as NSObject, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSObject, forKey: NSInferMappingModelAutomaticallyOption)

            // adding store by path and options
            persistentContainer.persistentStoreCoordinator.addPersistentStore(
                with: description
            ) { description, error in
                if let error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }

            // testing new model
            do {
                let model = try NSMappingModel.inferredMappingModel(
                    forSourceModel: persistentContainer.managedObjectModel,
                    destinationModel: persistentContainer.managedObjectModel
                )
                print(model)
            } catch {
                print(error)
            }

            return persistentContainer
        }.singleton
    }
}
