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

    enum ImageState {
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

        // First of all we need to check if image for url is present.
        // There will be three scenarios:
        //
        //   1. state is nil
        //      That means that no image is present for this url, and no image is being loaded. We must start the
        //      loading in this case and set state to .loading, so other threads won't do the same thing.
        //
        //   2. state is .loading
        //      In this case we just need to add index of this cell to set of indices for this URL. When image is
        //      loaded, cell will be notified automatically.
        //
        //   3. state is .ready
        //      No loading goes on, so we must notify cell ourselves. Calling a delegate and returning.

        var state: ImageState?
        var image: UIImage?
        serialQueue.sync {
            state = imageState[url]
            switch state {
            case .loading:
                urlToCell[url]?.insert(index)

            case .ready:
                image = imageStorage[url]

            case nil:
                // We're setting state to loading because we've just found that image is not present.
                // Though we're leaving `nil` value in variable `state`, because later we'll start downloading image.
                imageState[url] = .loading
            }
        }

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
    }

    func reset() async {
        serialQueue.sync {
            urlToCell.removeAll()
            imageStorage.removeAll()
        }
    }

    // MARK: Private methods

    private func downloadImage(at url: URL) async {
        guard let image = await imageService.prepareImage(at: url) else {
            serialQueue.sync {
                // Download failed, so we're setting initial values to state and image.
                // TODO: Add error state
                imageState[url] = nil
                imageStorage[url] = nil
            }
            return
        }

        // Image is downloaded now.

        serialQueue.sync {
            imageState[url] = .ready
            imageStorage[url] = image
            guard let cellsIndices = urlToCell[url] else {
                return
            }
            delegate?.imageLoaded(image, forCellsAt: cellsIndices)
        }
    }
}
