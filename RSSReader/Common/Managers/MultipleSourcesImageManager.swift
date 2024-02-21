//
//  MultipleSourcesImageManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 20.02.24.
//

import Foundation
import UIKit

protocol MultipleSourcesImageManagerDelegate: AnyObject {
    func imageLoaded(_ image: UIImage, for url: URL)
}

class MultipleSourcesImageManager {

    // MARK: Constants

    private enum ImageState {
        case loading
        case ready
    }

    // MARK: Internal properties

    weak var delegate: MultipleSourcesImageManagerDelegate?

    // MARK: Private properties

    /// Must be accessed inside `serialQueue` only.
    private var imageStorage: [URL: UIImage] = [:]

    /// Must be accessed inside `serialQueue` only.
    private var imageState: [URL: ImageState] = [:]

    private let serialQueue: DispatchQueue
    private static var serialQueueCounter = 0

    private let imageService: FeedImageService

    // MARK: Initialization

    init(imageService: FeedImageService = FeedImageService()) {
        self.imageService = imageService

        // initializing serial queue
        serialQueue = DispatchQueue(
            label: "\(String(describing: Self.self)).\(Self.serialQueueCounter)",
            qos: .utility
        )
        Self.serialQueueCounter += 1
    }

    // MARK: Internal methods

    func addURL(url: URL) async {
        let state = await processURL(url)
        var image: UIImage?

        switch state {
        case .loading, .ready:
            return

        case nil:
            image = await imageService.prepareImage(at: url)
        }

        guard let image else {
            await setErrorState(for: url)
            return
        }

        await setDownloadedImage(image, for: url)
        delegate?.imageLoaded(image, for: url)
    }

    func image(for url: URL) async -> UIImage? {
        await getImageFromStorage(for: url)
    }

    // MARK: Private methods
    
    /// Checks the state of image.
    /// Performs on private queue.
    /// - Parameter url: URL of image.
    /// - Returns: Image state at moment of calling function.
    private func processURL(_ url: URL) async -> ImageState? {
        serialQueue.sync {
            let state = imageState[url]
            switch state {
            case .loading, .ready:
                break

            case nil:
                imageState[url] = .loading
            }
            return state
        }
    }

    /// Saves downloaded image in object property.
    /// Performs on private queue.
    /// - Parameter image: Downloaded image.
    /// - Parameter url: URL of downloaded image.
    private func setDownloadedImage(_ image: UIImage, for url: URL) async {
        serialQueue.sync {
            imageState[url] = .ready
            imageStorage[url] = image
        }
    }

    /// Sets error state for image.
    /// Performs on private queue.
    /// - Parameter url: URL of image to set error state to.
    private func setErrorState(for url: URL) async {
        serialQueue.sync {
            // Download failed, so we're setting initial values to state and image.
            // TODO: Add error state
            imageState[url] = nil
            imageStorage[url] = nil
        }
    }
    
    /// Gets saved image if possible.
    /// Performs on private queue.
    /// - Parameter url: URL of image.
    /// - Returns: Image (if present).
    private func getImageFromStorage(for url: URL) async -> UIImage? {
        serialQueue.sync {
            switch imageState[url] {
            case nil, .loading:
                return nil

            case .ready:
                guard let image = imageStorage[url] else {
                    assertionFailure("Image must be present on ready state.")
                    return nil
                }
                return image
            }
        }
    }
}
