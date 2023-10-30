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

    func prepareFeed(at url: URL, completion: @escaping (Feed?) -> Void) {
        let parser = FeedParser(URL: url)
        parser.parseAsync { result in
            switch result {
            case .success(let feed):
                completion(feed)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }

    }

}
