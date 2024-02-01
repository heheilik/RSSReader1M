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

    func fill(with rssFeed: RSSFeed) {
        fatalError("Not implemented.", file: #file, line: #line)
    }

}
