//
//  FeedEntriesContext.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import Foundation
import FeedKit

struct FeedEntriesContext: PageContext {

    let feedName: String
    let rssFeed: RSSFeed

}
