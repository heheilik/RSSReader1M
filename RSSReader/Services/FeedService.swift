//
//  FeedService.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 26.10.23.
//

import FeedKit
import Foundation

class FeedService {

    // MARK: Internal Methods

    func prepareFeed(at url: URL) async -> Feed? {
        let parser = FeedParser(URL: url)
        let parsingTask = Task {
            parser.parse()
        }
        let result = await parsingTask.value
        guard case let .success(feed) = result else {
            return nil
        }
        return feed
    }

}
