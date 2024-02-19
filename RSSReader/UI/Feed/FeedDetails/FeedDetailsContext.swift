//
//  FeedDetailsContext.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import ALNavigation
import CoreData
import Foundation
import UIKit

struct FeedDetailsContext: PageContext {
    let title: String
    let description: String?
    let date: String?
    let image: UIImage?

    let persistenceManager: SingleFeedPersistenceManager
    let managedObject: ManagedFeedEntry
}
