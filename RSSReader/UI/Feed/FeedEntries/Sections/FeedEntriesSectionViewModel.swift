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

    override var registeredHeaderFooterTypes: [FMHeaderFooterView.Type] {[
        UnseenEntriesAmountTableViewHeader.self
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
        configureHeader()

        let imageURL = persistenceManager.fetchedResultsController.fetchedObjects?.first?.feed?.imageURL
        self.downloadImageIfPossible(imageURL: imageURL)
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

            // TODO: Move to function
            var dateString: String? = nil
            if let date = entry.date {
                dateString = dateFormatter.string(from: date)
            }

            return FeedEntriesCellViewModel(
                title: entry.title,
                description: entry.entryDescription,
                date: dateString,
                orderID: entry.orderID,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            )
        })
    }

    private func configureHeader() {
        headerViewModel = UnseenEntriesAmountHeaderViewModel(text: "test")
    }

    private func updateHeader(unseenEntriesAmount: Int64) {
        guard let headerViewModel = headerViewModel as? UnseenEntriesAmountHeaderViewModel else {
            return
        }
        headerViewModel.text = "\(unseenEntriesAmount) new entries."
        headerViewModel.view?.fill(viewModel: headerViewModel)
    }

    private func downloadImageIfPossible(imageURL: URL?) {
        guard let imageURL else {
            downloadedImage = nil
            return
        }
        Task { [weak self] in
            guard let self = self else {
                return
            }

            let image = await self.feedImageService.prepareImage(at: imageURL)

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
