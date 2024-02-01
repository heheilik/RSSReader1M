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

        guard let items = rssFeed.items else {
            return false
        }
        for item in items {
            let managedFeedEntry = ManagedFeedEntry(context: context)
            guard managedFeedEntry.fill(with: item, orderID: Int64.max) else {
                return false
            }
            addToEntries(managedFeedEntry)
        }
        return true
    }
}
