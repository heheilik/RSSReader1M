//
//  FeedEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import CoreData
import Foundation
import FMArchitecture
import UIKit

protocol FeedEntriesSectionViewModelDelegate: AnyObject {
    func beginTableUpdates()
    func endTableUpdates()
}

final class FeedEntriesSectionViewModel: FMSectionViewModel {

    // MARK: Constants

    private enum Image {
        static let error = UIImage(systemName: "photo")!
    }

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntryTableViewCell.self
    ]}

    override var registeredHeaderFooterTypes: [FMHeaderFooterView.Type] {[
        UnreadEntriesAmountTableViewHeader.self
    ]}

    var image: UIImage {
        downloadedImage ?? Image.error
    }

    // MARK: Private properties

    private let feedImageService: FeedImageService

    private let persistenceManager: SingleFeedPersistenceManager
    private let updateManager: FeedUpdateManager

    private var cellUpdateManager = FeedEntriesCellUpdateContainer()

    private var selectedViewModel: FeedEntryCellViewModel?

    private var downloadedImage: UIImage? {
        didSet {
            for cellViewModel in self.cellViewModels {
                guard let viewModel = cellViewModel as? FeedEntryCellViewModel else {
                    continue
                }
                viewModel.image = image
            }
        }
    }

    private var unreadEntriesCount: Int {
        didSet {
            updateHeader(unreadEntriesCount: unreadEntriesCount)
        }
    }

    private weak var currentDelegate: FeedEntriesSectionViewModelDelegate? {
        delegate as? FeedEntriesSectionViewModelDelegate
    }

    // MARK: Initialization

    init(
        context: FeedEntriesContext,
        feedImageService: FeedImageService = FeedImageService()
    ) {
        self.feedImageService = feedImageService

        persistenceManager = context.feedPersistenceManager
        updateManager = FeedUpdateManager(persistenceManager: context.feedPersistenceManager)

        unreadEntriesCount = context.unreadEntriesCount

        super.init()
        persistenceManager.fetchedResultsController.delegate = self

        configureCellViewModels(context: context)
        configureHeader()

        Task {
            await updateFeed()
        }

        let controller = persistenceManager.fetchedResultsController
        controller.managedObjectContext.perform { [weak self] in
            self?.downloadImageIfPossible(
                imageURL: controller.fetchedObjects?.first?.feed?.imageURL
            )
        }
    }

    // MARK: Internal methods

    @discardableResult
    func saveFeedToCoreData() async -> Bool {
        await persistenceManager.saveControllerData()
    }

    func updateFeed() async {
        let result = await updateManager.updateFeed()
        switch result {
        case let .failure(error):
            print(error)
        case .success():
            break
        }
    }

    func updateOnAppear() {
        guard
            let cellViewModel = selectedViewModel,
            let cell = cellViewModel.fillableCell as? FeedEntryTableViewCell
        else {
            return
        }
        cell.changeFavouriteStatus(isFavourite: cellViewModel.isFavourite)
        selectedViewModel = nil
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
            return FeedEntryCellViewModel(
                managedObject: entry,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            )
        })
    }

    private func configureHeader() {
        headerViewModel = UnreadEntriesAmountHeaderViewModel(unreadEntriesCount: self.unreadEntriesCount)
    }

    private func updateHeader(unreadEntriesCount: Int) {
        (headerViewModel as? UnreadEntriesAmountHeaderViewModel)?.unreadEntriesCount = unreadEntriesCount
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

// MARK: - FeedEntryCellViewModelDelegate

extension FeedEntriesSectionViewModel: FeedEntryCellViewModelDelegate {
    func readStatusChanged(isRead: Bool) {
        unreadEntriesCount += isRead ? -1 : 1
    }

    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel) {
        cellViewModel.isFavourite = !cellViewModel.isFavourite
    }

    func didSelect(cellViewModel: FeedEntryCellViewModel) {
        selectedViewModel = cellViewModel
        Router.shared.push(
            FeedPageFactory.NavigationPath.feedDetails.rawValue,
            animated: true,
            context: FeedDetailsContext(
                title: cellViewModel.title,
                entryDescription: cellViewModel.entryDescription,
                date: cellViewModel.date,
                image: image,
                persistenceManager: persistenceManager,
                managedObject: cellViewModel.managedObject
            )
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FeedEntriesSectionViewModel: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.currentDelegate?.beginTableUpdates()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            self.cellUpdateManager.ordered.forEach {
                self.cellViewModels.insert($0.viewModel, at: $0.index)
            }
            self.dataManipulator?.cellsAdded(
                at: cellUpdateManager.indexSet,
                on: self,
                with: .top,
                completion: nil
            )
            self.currentDelegate?.endTableUpdates()
            self.cellUpdateManager.removeAll()

            Task {
                guard
                    let unreadEntriesCount = await self.persistenceManager.fetchUnreadEntriesCount(
                        for: self.persistenceManager.url
                    )
                else {
                    return
                }
                async let _ = MainActor.run {
                    self.updateHeader(unreadEntriesCount: unreadEntriesCount)
                }
            }
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let managedFeedEntry = anObject as? ManagedFeedEntry else {
            assertionFailure("This class works with ManagedFeedEntry only.")
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("indexPath must not be nil in this case.")
                return
            }

            guard let viewModel = FeedEntryCellViewModel(
                managedObject: managedFeedEntry,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            ) else {
                assertionFailure("Model must be created here.")
                return
            }

            cellUpdateManager.add(
                index: newIndexPath.row,
                viewModel: viewModel
            )

        case .update:
            break

        case .delete:
            assertionFailure("Old content must not be deleted.")
            return

        case .move:
            assertionFailure("Old content must not be moved.")
            return

        @unknown default:
            assertionFailure("Case is not processed.")
            return
        }
    }
}
