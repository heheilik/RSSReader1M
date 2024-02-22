//
//  FeedImageService.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import Foundation
import UIKit

final class FeedImageService {

    // MARK: Private properties

    private let urlSession: URLSession

    // MARK: Initialization

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: Internal methods

    func prepareImage(at url: URL) async -> UIImage? {
        let result = try? await urlSession.data(from: url)

        guard let result else {
            return nil
        }

        let (data, _) = result
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}
