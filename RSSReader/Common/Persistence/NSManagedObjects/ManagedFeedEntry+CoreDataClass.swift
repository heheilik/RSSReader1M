//
//  ManagedFeedEntry+CoreDataClass.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 12.02.24.
//

import CoreData
import FeedKit
import Foundation

@objc(ManagedFeedEntry)
public class ManagedFeedEntry: NSManagedObject {

    // MARK: Internal methods

    func fill(with rssFeedItem: RSSFeedItem) -> Bool {
        guard let title = rssFeedItem.title else {
            return false
        }
        self.title = title

        entryDescription = rssFeedItem.description
        date = rssFeedItem.pubDate
        isRead = false

        return true
    }
}
