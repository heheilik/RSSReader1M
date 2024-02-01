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

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntriesCell.self
    ]}

    var image: UIImage {
        downloadedImage ?? Self.errorImage
    }

    // MARK: Private properties

    private let feedImageService: FeedImageService

    private let persistenceManager: FeedPersistenceManager

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
        persistenceManager = context.feedPersistenceManager
        super.init()
        configureCellViewModels(context: context)

//        self.downloadImageIfPossible(
//            feedURLString: context.rssFeed.link,
//            imageURLString: context.rssFeed.image?.url
//        )
    }

    // MARK: Private methods

    private func configureCellViewModels(context: FeedEntriesContext) {
        guard let managedFeedEntries = persistenceManager.fetchedResultsController.fetchedObjects else {
            return
        }
        reload(cellModels: managedFeedEntries.compactMap { [weak self] entry in
            guard let self else {
                return nil
            }

            var dateString: String? = nil
            if let date = entry.date {
                dateString = dateFormatter.string(from: date)
            }

            return FeedEntriesCellViewModel(
                title: entry.title,
                description: entry.entryDescription,
                date: dateString,
                image: Self.errorImage,
                delegate: self,
                isAnimatedAtStart: false
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

        Task { [weak self] in
            guard let self = self else {
                return
            }

            let image = await self.feedImageService.prepareImage(at: url)
            guard let image else {
                self.downloadedImage = nil
                return
            }
            self.downloadedImage = image
        }
    }

}

// MARK: - FMAnimatable

extension FeedEntriesSectionViewModel: FMAnimatable { }
