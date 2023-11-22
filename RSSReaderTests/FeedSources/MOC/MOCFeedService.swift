//
//  MOCFeedService.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import FeedKit
import Foundation

class MOCFeedService: FeedService {

    var prepareFeedCalled = false

    override func prepareFeed(at url: URL, completion: @escaping (Feed?) -> Void) {
        prepareFeedCalled = true
        completion(nil)
    }

}
