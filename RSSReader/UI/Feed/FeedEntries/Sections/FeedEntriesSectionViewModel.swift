//
//  FeedEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import CoreData
import Foundation
import FMArchitecture
import UIKit

protocol FeedEntriesSectionViewModelDelegate: AnyObject {
    func beginTableUpdates()
    func endTableUpdates()
}

class FeedEntriesSectionViewModel: FMSectionViewModel {

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntriesCell.self
    ]}

    override var registeredHeaderFooterTypes: [FMHeaderFooterView.Type] {[
        UnreadEntriesAmountTableViewHeader.self
    ]}

    var image: UIImage {
        downloadedImage ?? Self.errorImage
    }

    // MARK: Private properties

    private let feedImageService: FeedImageService

    private let persistenceManager: FeedPersistenceManager
    private let updateManager: FeedUpdateManager
    private let fetchedResultsControllerDelegate: FeedEntriesFetchedResultsControllerDelegate

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

    private var unreadEntriesCount: Int {
        didSet {
            updateHeader(unreadEntriesCount: unreadEntriesCount)
        }
    }
    
    private static let errorImage = UIImage(systemName: "photo")!

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
        fetchedResultsControllerDelegate = FeedEntriesFetchedResultsControllerDelegate()

        unreadEntriesCount = context.unreadEntriesCount

        super.init()

        fetchedResultsControllerDelegate.sectionViewModel = self
        persistenceManager.fetchedResultsController.delegate = fetchedResultsControllerDelegate

        configureCellViewModels(context: context)
        configureHeader()

        startFeedUpdate()

        let imageURL = persistenceManager.fetchedResultsController.fetchedObjects?.first?.feed?.imageURL
        self.downloadImageIfPossible(imageURL: imageURL)
    }

    // MARK: Internal methods

    @discardableResult
    func saveFeedToCoreData() async -> Bool {
        await persistenceManager.saveControllerData()
    }

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        addedObject object: ManagedFeedEntry,
        at indexPath: IndexPath
    ) {
        print("add   : \(indexPath.row), title: \(object.title ?? "nil")")
        cellViewModels.insert(
            FeedEntriesCellViewModel(
                managedObject: object,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            ),
            at: indexPath.row
        )
        dataManipulator?.cellsAdded(
            at: IndexSet(integer: indexPath.row),
            on: self,
            with: .fade,
            completion: nil
        )
    }

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        removedObject object: ManagedFeedEntry,
        at indexPath: IndexPath
    ) {
        print("remove : \(indexPath.row), title: \(object.title ?? "nil")")
        cellViewModels.remove(at: indexPath.row)
        dataManipulator?.cellsDeleted(
            at: IndexSet(integer: indexPath.row),
            on: self,
            with: .fade,
            completion: nil
        )
    }

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        movedObject object: ManagedFeedEntry,
        from oldIndexPath: IndexPath,
        to newIndexPath: IndexPath
    ) {
        print("move   : \(oldIndexPath.row) -> \(newIndexPath.row), title: \(object.title ?? "nil")")
        
        // removing
        cellViewModels.remove(at: oldIndexPath.row)
        dataManipulator?.cellsDeleted(
            at: IndexSet(integer: oldIndexPath.row),
            on: self,
            with: .fade,
            completion: nil
        )

        // adding
        cellViewModels.insert(
            FeedEntriesCellViewModel(
                managedObject: object,
                image: image,
                delegate: self,
                isAnimatedAtStart: false
            ),
            at: newIndexPath.row
        )
        dataManipulator?.cellsAdded(
            at: IndexSet(integer: newIndexPath.row),
            on: self,
            with: .fade,
            completion: nil
        )
    }

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        updatedObject object: ManagedFeedEntry,
        at indexPath: IndexPath
    ) {
        print("update : \(indexPath.row), title: \(object.title ?? "nil")")
        let cellViewModel = FeedEntriesCellViewModel(
            managedObject: object,
            image: image,
            delegate: self,
            isAnimatedAtStart: false
        )
        refresh(cellModels: [cellViewModel])
    }

    func fetchedResultsControllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("--- Updates started ---")
        currentDelegate?.beginTableUpdates()
    }

    func fetchedResultsControllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("--- Updates ended ---")
        currentDelegate?.endTableUpdates()
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
            return FeedEntriesCellViewModel(
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

    private func startFeedUpdate() {
        Task {
            let result = await updateManager.updateFeed()
            switch result {
            case let .failure(error):
                print(error)
            case .success():
                break
            }
        }
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

// MARK: - FeedEntriesCellViewModelDelegate

extension FeedEntriesSectionViewModel: FeedEntriesCellViewModelDelegate {
    func readStatusChanged(isRead: Bool) {
        unreadEntriesCount += isRead ? -1 : 1
    }
}
