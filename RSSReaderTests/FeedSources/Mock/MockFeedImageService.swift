//
//  MockFeedImageService.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 23.11.23.
//

import FMArchitecture
import UIKit
@testable import RSSReader

final class MockFeedImageService: FeedImageService {

    enum Constants {
        static let imageLinkString = "image.img"
        static let separatedImageFeedURL = MockFeedFactory.urlForConfig(
            feedType: .rss,
            itemConfig: .noItems,
            imageConfig: .separatedLink
        )
        static let separatedImageURL = URL(string: imageLinkString)!
        static let fullURL = URL(
            string: MockFeedFactory.urlForConfig(
                feedType: .rss,
                itemConfig: .noItems,
                imageConfig: .fullLink
            ).absoluteString + imageLinkString
        )!

        static let correctImage = UIImage(systemName: "figure.dance")!
        static let errorImage = UIImage(systemName: "photo")!
    }

    var calledPrepareImage = false

    override func prepareImage(at url: URL) async -> UIImage? {
        calledPrepareImage = true
        let urlIsCorrect = url == Constants.fullURL || url == URL(
            string: Constants.separatedImageFeedURL.absoluteString + Constants.separatedImageURL.absoluteString
        )
        return urlIsCorrect ? Self.Constants.correctImage : nil
    }

}
