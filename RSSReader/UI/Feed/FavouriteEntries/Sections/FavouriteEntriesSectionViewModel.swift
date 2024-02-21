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
        imageManager: MultipleSourcesImageManager = MultipleSourcesImageManager()
    ) {
        persistenceManager = context.persistenceManager
        self.imageManager = imageManager

        super.init()

        persistenceManager.fetchedResultsController.delegate = self
        imageManager.delegate = self
        configureCellViewModels()
    }

    // MARK: Internal methods

    func saveFeedToCoreData() async {
        await persistenceManager.saveControllerData()
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
                    await self.imageManager.addEntryData(index: index, url: imageURL)
                }
            }
        }
    }
}

// MARK: - FeedEntryCellViewModelDelegate

extension FavouriteEntriesSectionViewModel: FeedEntryCellViewModelDelegate {
    func readStatusChanged(isRead: Bool) { }

    func didSelect(cellViewModel: FeedEntryCellViewModel) {
//        selectedViewModel = cellViewModel
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
    func imageLoaded(_ image: UIImage, forCellAt index: Int) {
        (cellModel(at: index) as? FeedEntryCellViewModel)?.image = image
    }
    
    func imageLoaded(_ image: UIImage, forCellsAt indices: Set<Int>) {
        indices
            .compactMap { cellViewModels[safe: $0] as? FeedEntryCellViewModel }
            .forEach { $0.image = image }
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
                    image: UIImage(),
                    delegate: self,
                    isAnimatedAtStart: false
                ) else {
                    return
                }
                self.cellViewModels[index] = viewModel
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
