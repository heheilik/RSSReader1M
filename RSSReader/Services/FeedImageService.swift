//
//  FeedImageService.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import Foundation
import UIKit

class FeedImageService {

    // MARK: Private properties

    private let urlSession: URLSession

    // MARK: Initialization

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: Internal methods

    func prepareImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = urlSession.dataTask(with: URLRequest(url: url)) { data, _, error in
            var image: UIImage?
            defer {
                completion(image)
            }

            guard
                error == nil,
                let data
            else {
                return
            }

            image = UIImage(data: data)
        }
        task.resume()
    }

}
