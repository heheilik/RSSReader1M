//
//  ManagedFeedEntry+CoreDataProperties.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.02.24.
//

import Foundation
import CoreData

extension ManagedFeedEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedEntry> {
        return NSFetchRequest<ManagedFeedEntry>(entityName: "ManagedFeedEntry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var entryDescription: String?
    @NSManaged public var orderID: Int64
    @NSManaged public var title: String?
    @NSManaged public var feed: ManagedFeed?

}

extension ManagedFeedEntry: Identifiable {

}
