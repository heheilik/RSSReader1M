//
//  FeedService.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 26.10.23.
//

import FeedKit
import Foundation

final class FeedService {

    // MARK: Internal Methods

    func prepareFeed(at url: URL) async -> Feed? {
        let parser = FeedParser(URL: url)
        let parsingTask = Task {
            parser.parse()
        }

        let result = await parsingTask.value
        switch result {
        case .success(let feed):
            return feed
        case .failure(_):
            return nil
        }
    }

}
