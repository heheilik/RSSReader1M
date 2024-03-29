//
//  ManagedFeed+CoreDataClass.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 12.02.24.
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

        self.url = url
        imageURL = getImageURL(from: rssFeed.image)

        guard let items = rssFeed.items else {
            return false
        }
        for item in items {
            let managedFeedEntry = ManagedFeedEntry(context: context)
            guard managedFeedEntry.fill(with: item) else {
                return false
            }
            addToEntries(managedFeedEntry)
        }

        return true
    }

    // MARK: Private methods

    private func getImageURL(from image: RSSFeedImage?) -> URL? {
        guard let imageURLString = image?.url else {
            return nil
        }
        if imageURLString.starts(with: "http") {
            return URL(string: imageURLString)
        }

        guard let feedURLString = image?.link else {
            return nil
        }
        print(feedURLString)
        print(imageURLString)
        return URL(string: feedURLString + imageURLString)
    }
}
