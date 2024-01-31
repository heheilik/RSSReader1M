//
//  Feed+CoreDataProperties.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import Foundation
import CoreData

extension Feed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var url: URL?
    @NSManaged public var imageLink: URL?
    @NSManaged public var lastReadOrderID: Int64
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension Feed {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: FeedEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: FeedEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

extension Feed : Identifiable {

}
