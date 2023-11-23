//
//  MockFeedImageService.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FMArchitecture
import UIKit

class MockFeedImageService: FeedImageService {

    enum Constants {
        static let correctURL = URL(string: "https://image.url")!
        static let correctImage = UIImage(systemName: "figure.dance")!
        static let errorImage = UIImage(systemName: "error")!
    }

    var calledPrepareImage = false

    override func prepareImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        calledPrepareImage = true
        completion(url == Constants.correctURL ? Self.Constants.correctImage : nil)
    }

}
