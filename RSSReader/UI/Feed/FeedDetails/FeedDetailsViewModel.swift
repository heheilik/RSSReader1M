//
//  FeedDetailsViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import CoreData
import FMArchitecture
import Foundation
import UIKit

class FeedDetailsViewModel: FMPageViewModel {

    // MARK: Internal properties

    let title: String
    let description: String?
    let date: String?
    let image: UIImage?

    var isFavourite: Bool {
        didSet {
            saveFavouriteStatusToContext()
        }
    }

    // MARK: Private properties

    private let managedObject: ManagedFeedEntry
    private let persistenceManager: FeedPersistenceManager

    // MARK: Initialization

    init(context: FeedDetailsContext) {
        title = context.title
        description = context.description
        date = context.date
        image = context.image

        managedObject = context.managedObject
        persistenceManager = context.persistenceManager

        isFavourite = false

        super.init()

        loadFavouriteStatusFromStorage()
    }

    // MARK: Internal methods

    func saveToDatabase() {
        Task {
            await persistenceManager.saveControllerData()
        }
    }

    // MARK: Private methods

    private func loadFavouriteStatusFromStorage() {
        guard let context = managedObject.managedObjectContext else {
            assertionFailure("Object must exist in some context.")
            return
        }
        context.performAndWait {
            self.isFavourite = managedObject.isFavourite
        }
    }

    private func saveFavouriteStatusToContext() {
        guard let context = managedObject.managedObjectContext else {
            assertionFailure("Object must exist in some context.")
            return
        }
        context.performAndWait {
            managedObject.isFavourite = self.isFavourite
        }
    }
}
