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

    // MARK: Private properties

    private let managedObject: NSManagedObject
    private let persistenceManager: FeedPersistenceManager

    // MARK: Initialization

    init(context: FeedDetailsContext) {
        title = context.title
        description = context.description
        date = context.date
        image = context.image

        managedObject = context.managedObject
        persistenceManager = context.persistenceManager

        super.init()
    }
}
