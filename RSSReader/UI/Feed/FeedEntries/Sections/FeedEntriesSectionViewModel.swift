//
//  FeedEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture
import UIKit

class FeedEntriesSectionViewModel: FMSectionViewModel {

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntriesCell.self
    ]}

    // MARK: Internal properties

    var image: UIImage {
        downloadedImage ?? Self.errorImage
    }

    // MARK: Private properties

    private let feedImageService: FeedImageService

    private var downloadedImage: UIImage? {
        didSet {
            for cellViewModel in self.cellViewModels {
                guard let viewModel = cellViewModel as? FeedEntriesCellViewModel else {
                    continue
                }
                viewModel.image = image
            }
        }
    }

    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private static let errorImage = UIImage(systemName: "photo")!

    // MARK: Initialization

    init(
        context: FeedEntriesContext,
        feedImageService: FeedImageService = FeedImageService()
    ) {
        self.feedImageService = feedImageService
        super.init()
        configureCellViewModels(context: context)
        self.downloadImageIfPossible(
            feedURLString: context.rssFeed.link,
            imageURLString: context.rssFeed.image?.url
        )
    }

    // MARK: Private methods

    private func configureCellViewModels(context: FeedEntriesContext) {
        guard let feedItems = context.rssFeed.items else {
            cellViewModels = []
            return
        }
        cellViewModels = feedItems.map({ item in
            let date: String?
            if let typedDate = item.pubDate {
                date = dateFormatter.string(from: typedDate)
            } else {
                date = nil
            }
            return FeedEntriesCellViewModel(
                title: item.title,
                description: item.description,
                date: date,
                image: image,
                delegate: self
            )
        })
    }

    private func downloadImageIfPossible(feedURLString: String?, imageURLString: String?) {
        guard let imageURLString else {
            downloadedImage = nil
            return
        }

        let url: URL
        if imageURLString.starts(with: "http") {
            guard let tempURL = URL(string: imageURLString) else {
                downloadedImage = nil
                return
            }
            url = tempURL
        } else {
            guard
                let feedURLString,
                let tempURL = URL(string: feedURLString + imageURLString)
            else {
                downloadedImage = nil
                return
            }
            url = tempURL
        }

        feedImageService.prepareImage(at: url) { [weak self] image in
            guard let self = self else {
                return
            }
            guard let image else {
                self.downloadedImage = nil
                return
            }
            self.downloadedImage = image
        }
    }

}
