//
//  FeedEntry+CoreDataProperties.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import Foundation
import CoreData

extension FeedEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedEntry> {
        return NSFetchRequest<FeedEntry>(entityName: "FeedEntry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var entryDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var guid: UUID?
    @NSManaged public var orderID: Int64
    @NSManaged public var feed: Feed?

}

extension FeedEntry : Identifiable {

}
