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
        static let imageLinkString = "image.img"
        static let separatedImageFeedURL = MockFeeds.mockRSSSeparatedImageLink.url
        static let separatedImageURL = URL(string: imageLinkString)!
        static let fullURL = URL(string: MockFeeds.mockRSSFullImageLink.url.absoluteString + imageLinkString)!

        static let correctImage = UIImage(systemName: "figure.dance")!
        static let errorImage = UIImage(systemName: "error")!
    }

    var calledPrepareImage = false

    override func prepareImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        calledPrepareImage = true
        let urlIsCorrect = url == Constants.fullURL || url == URL(
            string: Constants.separatedImageFeedURL.absoluteString + Constants.separatedImageURL.absoluteString
        )
        completion(urlIsCorrect ? Self.Constants.correctImage : nil)
    }

}
