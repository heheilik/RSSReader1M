//
//  ManagedFeed+CoreDataClass.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import CoreData
import FeedKit
import Foundation

@objc(ManagedFeed)
public class ManagedFeed: NSManagedObject {

    // MARK: Internal methods

    func fill(with rssFeed: RSSFeed, url: URL) -> Bool {
        guard let context = managedObjectContext else {
            return false
        }

        if let urlString = rssFeed.image?.link,
           let imageURL = URL(string: urlString) {
            imageLink = imageURL
        }
        self.url = url
        lastReadOrderID = 0

        guard let items = rssFeed.items else {
            return false
        }
        var currentOrderID: Int64 = 0
        for item in items {
            let managedFeedEntry = ManagedFeedEntry(context: context)
            guard managedFeedEntry.fill(with: item, orderID: currentOrderID) else {
                return false
            }
            addToEntries(managedFeedEntry)
            currentOrderID += 1
        }
        return true
    }
}
