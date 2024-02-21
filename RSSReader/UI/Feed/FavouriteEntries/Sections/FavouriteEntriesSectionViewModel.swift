//
//  FavouriteEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import ALNavigation
import CoreData
import FMArchitecture
import Foundation
import UIKit

protocol FavouriteEntriesSectionViewModelDelegate: AnyObject {
    func beginTableUpdates()
    func endTableUpdates()
    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel)
}

class FavouriteEntriesSectionViewModel: FMSectionViewModel {

    // MARK: Constants

    private enum Image {
        static let error = UIImage(systemName: "photo")!
    }

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntryTableViewCell.self
    ]}

    // MARK: Private properties

    private var persistenceManager: FavouriteEntriesPersistenceManager
    private let imageManager: MultipleSourcesImageManager

    private let cellUpdateContainer = FavouriteEntriesCellUpdateContainer()

    private weak var currentDelegate: FavouriteEntriesSectionViewModelDelegate? {
        delegate as? FavouriteEntriesSectionViewModelDelegate
    }

    // MARK: Initialization

    init(
        context: FavouriteEntriesContext,
        delegate: FMSectionViewModelDelegate? = nil,
        imageManager: MultipleSourcesImageManager = MultipleSourcesImageManager()
    ) {
        persistenceManager = context.persistenceManager
        self.imageManager = imageManager

        super.init(delegate: delegate)

        persistenceManager.fetchedResultsController.delegate = self
        imageManager.delegate = self
        configureCellViewModels()
    }

    // MARK: Internal methods

    func saveFeedToCoreData() async {
        await persistenceManager.saveControllerData()
    }

    func removeFromFavourites(cellViewModel: FeedEntryCellViewModel) {
        cellViewModel.isFavourite = !cellViewModel.isFavourite
        Task {
            await saveFeedToCoreData()
        }
    }

    // MARK: Private methods

    private func configureCellViewModels() {
        guard let managedFeedEntries = persistenceManager.fetchedResultsController.fetchedObjects else {
            return
        }
        reload(cellModels: managedFeedEntries.enumerated().compactMap { [weak self] (index, entry) in
            guard let self else {
                return nil
            }
            return FeedEntryCellViewModel(
                managedObject: entry,
                image: Image.error,
                delegate: self,
                isAnimatedAtStart: false
            )
        })
        managedFeedEntries.enumerated().forEach { [weak self] (index, entry) in
            guard let self else {
                return
            }
            entry.managedObjectContext?.perform {
                guard let imageURL = entry.feed?.imageURL else {
                    return
                }
                Task {
                    await self.imageManager.addURL(url: imageURL)
                }
            }
        }
    }
}

// MARK: - FeedEntryCellViewModelDelegate

extension FavouriteEntriesSectionViewModel: FeedEntryCellViewModelDelegate {
    func readStatusChanged(isRead: Bool) { }

    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel) {
        guard cellViewModel.isFavourite else {
            return
        }
        currentDelegate?.cellViewModelActivatedFavouriteButton(cellViewModel)
    }

    func didSelect(cellViewModel: FeedEntryCellViewModel) {
        Router.shared.push(
            FeedPageFactory.NavigationPath.feedDetails.rawValue,
            animated: true,
            context: FeedDetailsContext(
                title: cellViewModel.title,
                entryDescription: cellViewModel.entryDescription,
                date: cellViewModel.date,
                image: cellViewModel.image,
                persistenceManager: persistenceManager,
                managedObject: cellViewModel.managedObject
            )
        )
    }
}

// MARK: - MultipleSourcesImageManagerDelegate

extension FavouriteEntriesSectionViewModel: MultipleSourcesImageManagerDelegate {
    func imageLoaded(_ image: UIImage, for url: URL) {
        persistenceManager.controllerContext.perform { [weak self] in
            self?.cellViewModels
                .compactMap { $0 as? FeedEntryCellViewModel }
                .filter { $0.managedObject.feed?.imageURL == url }
                .forEach { $0.image = image }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FavouriteEntriesSectionViewModel: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.currentDelegate?.beginTableUpdates()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            cellViewModels.remove(atOffsets: cellUpdateContainer.deletedCellsIndices)
            dataManipulator?.cellsDeleted(
                at: cellUpdateContainer.deletedCellsIndices,
                on: self,
                with: .fade,
                completion: nil
            )

            cellUpdateContainer.updatedManagedObjects.forEach { (index, managedFeedEntry) in
                guard let viewModel = FeedEntryCellViewModel(
                    managedObject: managedFeedEntry,
                    image: Image.error,
                    delegate: self,
                    isAnimatedAtStart: false
                ) else {
                    return
                }
                self.cellViewModels[index] = viewModel

                Task {
                    var imageURL: URL?
                    self.persistenceManager.controllerContext.performAndWait {
                        imageURL = managedFeedEntry.feed?.imageURL
                    }
                    guard
                        let imageURL,
                        let image = await self.imageManager.image(for: imageURL)
                    else {
                        return
                    }
                    viewModel.image = image
                }
            }

            dataManipulator?.cellsUpdated(
                at: cellUpdateContainer.updatedIndexSet,
                on: self,
                with: .none,
                completion: nil
            )

            currentDelegate?.endTableUpdates()
            cellUpdateContainer.reset()
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .update:
            guard
                let indexPath,
                let managedFeedEntry = anObject as? ManagedFeedEntry
            else {
                assertionFailure("indexPath and ManagedFeedEntry must be provided as a parameters.")
                return
            }
            cellUpdateContainer.updateCell(at: indexPath.row, with: managedFeedEntry)

        case .delete:
            guard let indexPath else {
                assertionFailure("indexPath must be provided as a parameters.")
                return
            }
            cellUpdateContainer.deleteCell(at: indexPath.row)

        case .insert:
            assertionFailure("New content must not be inserted.")
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
