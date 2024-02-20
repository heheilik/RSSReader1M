//
//  MultipleSourcesImageManager.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 20.02.24.
//

import Foundation
import UIKit

protocol MultipleSourcesImageManagerDelegate: AnyObject {
    func imageLoaded(_ image: UIImage, forCellAt index: Int)
    func imageLoaded(_ image: UIImage, forCellsAt indices: Set<Int>)
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
    private var urlToCell: [URL: Set<Int>] = [:]

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

    func addEntryData(index: Int, url: URL) async {
        print("--- \(#function) call (index is \(index)) ---")

        let (image, state) = await processEntryData(url: url, index: index)

        switch state {
        case .loading:
            return

        case .ready:
            guard let image else {
                return
            }
            delegate?.imageLoaded(image, forCellAt: index)
            return

        case nil:
            break
        }

        // While image is in .loading state, this is the only scope that has access to image and imageState.
        // Depending on how image loading proceeds, we must set according state and, if possible, set image
        // as a result of our actions.

        await downloadImage(at: url)

        print("--- \(#function) return (index is \(index)) ---")
    }

    func removeEntryData(index: Int, url: URL) async {
        await removeEntryDataFromObject(url: url, index: index)
    }

    // MARK: Private methods

    /// Checks the data stored for added entry and reacts to it.
    /// Performs on private queue.
    /// - Parameters:
    ///   - url: URL of image of added entry.
    ///   - index: Index of added entry.
    /// - Returns: Image, if possible, and state of image at the moment of function call.
    ///
    /// There are 3 scenarios of image state:
    ///
    /// 1. `state` is `.loading`
    ///
    ///    In this case we need to add index of this cell to set of indices for this URL.
    ///    When image is loaded, cells with indices contained by this set will be notified.
    ///
    /// 2. `state` is `.ready`
    ///
    ///    No loading goes on, so we must notify cell ourselves. Calling a delegate and returning.
    ///
    /// 3. `state` is `nil`
    ///
    ///    That means that no image is present for this url, and no image is being loaded. We must start the
    ///    loading in this case and set state to .loading, so other threads won't do the same thing.
    ///
    private func processEntryData(url: URL, index: Int) async -> (UIImage?, ImageState?) {
        serialQueue.sync {
            var image: UIImage?
            let state = imageState[url]
            switch state {
            case .loading:
                break

            case .ready:
                image = imageStorage[url]

            case nil:
                urlToCell[url] = []
                // We're setting state to loading because we've just found that image is not present.
                // Though we're leaving `nil` value in variable `state`, because later we'll start downloading image.
                imageState[url] = .loading
            }
            urlToCell[url]?.insert(index)
            return (image, state)
        }
    }
    
    /// Performs all operation on downloading image and saving it in current object.
    /// - Parameter url: URL of image.
    private func downloadImage(at url: URL) async {
        guard let image = await imageService.prepareImage(at: url) else {
            await setErrorState(for: url)
            return
        }

        let cellsWithUpdatedImageIndices = await setDownloadedImage(image, for: url)
        delegate?.imageLoaded(image, forCellsAt: cellsWithUpdatedImageIndices)
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
    
    /// Saves downloaded image in object property.
    /// Performs on private queue.
    /// - Parameter image: Downloaded image.
    /// - Parameter url: URL of downloaded image.
    /// - Returns: Set of indices of cells that need to be notified.
    private func setDownloadedImage(_ image: UIImage, for url: URL) async -> Set<Int> {
        serialQueue.sync {
            imageState[url] = .ready
            imageStorage[url] = image
            return urlToCell[url] ?? []
        }
    }
    
    /// Removes data about cell from current object.
    /// Performs on private queue.
    /// - Parameters:
    ///   - url: URL of image of entry.
    ///   - index: Index of entry.
    private func removeEntryDataFromObject(url: URL, index: Int) async {
        serialQueue.sync {
            _ = urlToCell[url]?.remove(index)
        }
    }
}
