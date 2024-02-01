//
//  ManagedFeedEntry+CoreDataClass.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import FeedKit
import Foundation

@objc(ManagedFeedEntry)
public class ManagedFeedEntry: NSManagedObject {

    // MARK: Internal methods

    func fill(with rssFeedItem: RSSFeedItem, orderID: Int64) -> Bool {
        guard let title = rssFeedItem.title else {
            return false
        }
        self.title = title

        entryDescription = rssFeedItem.description
        date = rssFeedItem.pubDate
        self.orderID = orderID

        return true
    }

}
