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

    private var cellUpdateManager = FeedEntriesCellUpdateContainer()

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

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        addedObject object: ManagedFeedEntry,
        at indexPath: IndexPath
    ) {
        guard let viewModel = FeedEntriesCellViewModel(
            managedObject: object,
            image: image,
            delegate: self,
            isAnimatedAtStart: false
        ) else {
            assertionFailure("Model must be created here.")
            return
        }
        cellUpdateManager.add(
            viewModel: viewModel,
            index: indexPath.row
        )
    }

    func fetchedResultsController(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        updatedObject object: ManagedFeedEntry,
        at indexPath: IndexPath
    ) {
        guard let cellViewModel = FeedEntriesCellViewModel(
            managedObject: object,
            image: image,
            delegate: self,
            isAnimatedAtStart: false
        ) else {
            assertionFailure("Model must be created here.")
            return
        }
        refreshCells([cellViewModel])
    }

    func fetchedResultsControllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentDelegate?.beginTableUpdates()
    }

    func fetchedResultsControllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cellUpdateManager.ordered.forEach {
            cellViewModels.insert($0.viewModel, at: $0.index)
        }
        dataManipulator?.cellsAdded(
            at: cellUpdateManager.indexSet,
            on: self,
            with: .top,
            completion: nil
        )
        currentDelegate?.endTableUpdates()
        cellUpdateManager.removeAll()

        Task {
            guard
                let unreadEntriesCount = await persistenceManager.fetchUnreadEntriesCount(for: persistenceManager.url)
            else {
                return
            }
            async let _ = MainActor.run {
                self.updateHeader(unreadEntriesCount: unreadEntriesCount)
            }
        }
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

    func pushDetailsController(
        title: String,
        description: String?,
        date: String?,
        managedObject: NSManagedObject
    ) {
        Router.shared.push(
            FeedPageFactory.NavigationPath.feedDetails.rawValue,
            animated: true,
            context: FeedDetailsContext(
                title: title,
                description: description,
                date: date,
                image: image,
                persistenceManager: persistenceManager,
                managedObject: managedObject
            )
        )
    }
}
