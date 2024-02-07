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

    private var currentLastReadOrderID: Int64
    private var unseenEntriesAmount: Int64

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
        currentLastReadOrderID = context.lastReadOrderID

        guard let entriesAmount = persistenceManager.fetchedResultsController.fetchedObjects?.count else {
            fatalError("No entries fetched.")
            // TODO: Improve safety
        }
        unseenEntriesAmount = Int64(entriesAmount) -  context.lastReadOrderID

        super.init()
        configureCellViewModels(context: context)
        configureHeader()

        let imageURL = persistenceManager.fetchedResultsController.fetchedObjects?.first?.feed?.imageURL
        self.downloadImageIfPossible(imageURL: imageURL)
    }

    // MARK: Internal methods

    func updateVisibleCellsViewModelsList(with viewModels: [FeedEntriesCellViewModel]) {
        let maxCellOrderID = viewModels.reduce(currentLastReadOrderID) { maxOrderID, viewModel in
            max(maxOrderID, viewModel.orderID)
        }

        let difference = maxCellOrderID - currentLastReadOrderID
        if difference > 0 {
            unseenEntriesAmount -= difference
            updateHeader(unseenEntriesAmount: unseenEntriesAmount)
        }

        currentLastReadOrderID = maxCellOrderID
    }

    func heightOfPresentedContent() -> CGFloat {
        guard
            let lastReadOrderID =
                persistenceManager.fetchedResultsController.fetchedObjects?.first?.feed?.lastReadOrderID,
            let viewModels = cellViewModels as? [FeedEntriesCellViewModel]
        else {
            return 0
        }

        let filtered = viewModels.filter {
            $0.orderID < 10
        }
        print("Filtered count: \(filtered.count)")

        let mapped = filtered.compactMap {
            $0.fillableCell as? UIView
        }
        print("Mapped count: \(mapped.count)")

        let totalCellHeight = mapped.reduce(CGFloat(0)) { height, view in
            height + view.bounds.height
        }

//        let totalCellHeight = viewModels
//            .filter {
//                $0.orderID < 3
//            }
//            .compactMap {
//                $0.fillableCell as? UIView
//            }
//            .reduce(CGFloat(0)) { height, view in
//                height + view.bounds.height
//            }

        guard let headerHeight = headerViewModel?.view?.bounds.height else {
            return 0
        }

        return totalCellHeight + headerHeight
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
                orderID: entry.orderID,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            )
        })
    }

    private func configureHeader() {
        headerViewModel = UnseenEntriesAmountHeaderViewModel(text: "\(unseenEntriesAmount) new entries.")
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
