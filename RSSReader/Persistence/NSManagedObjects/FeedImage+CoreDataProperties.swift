//
//  FeedImage+CoreDataProperties.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.01.24.
//

import Foundation
import CoreData

extension FeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedImage> {
        return NSFetchRequest<FeedImage>(entityName: "FeedImage")
    }

    @NSManaged public var url: URL?
    @NSManaged public var image: Data?

}

extension FeedImage : Identifiable {

}
