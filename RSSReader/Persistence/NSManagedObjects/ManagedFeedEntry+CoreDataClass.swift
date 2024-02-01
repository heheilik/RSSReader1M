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

    func fill(with rssFeedItem: RSSFeedItem) {
        fatalError("Not implemented.", file: #file, line: #line)
    }

}
