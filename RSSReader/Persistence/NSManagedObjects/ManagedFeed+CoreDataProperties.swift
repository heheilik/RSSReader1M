//
//  ManagedFeed+CoreDataProperties.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.02.24.
//

import Foundation
import CoreData

extension ManagedFeed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged public var imageURL: URL?
    @NSManaged public var lastReadOrderID: Int64
    @NSManaged public var url: URL?
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension ManagedFeed {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: ManagedFeedEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: ManagedFeedEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

extension ManagedFeed: Identifiable {

}
