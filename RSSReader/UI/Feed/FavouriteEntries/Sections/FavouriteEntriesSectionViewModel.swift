//
//  FavouriteEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import ALNavigation
import FMArchitecture
import Foundation
import UIKit

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

    // MARK: Initialization

    init(
        context: FavouriteEntriesContext,
        imageManager: MultipleSourcesImageManager = MultipleSourcesImageManager()
    ) {
        self.persistenceManager = context.persistenceManager
        self.imageManager = imageManager
        super.init()
        imageManager.delegate = self
        configureCellViewModels()
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
            entry.managedObjectContext?.perform {
                guard let imageURL = entry.feed?.imageURL else {
                    return
                }
                Task {
                    await self.imageManager.addEntryData(index: index, url: imageURL)
                }
            }
            return FeedEntryCellViewModel(
                managedObject: entry,
                image: Image.error,
                delegate: self,
                isAnimatedAtStart: false
            )
        })
    }
}

// MARK: - FeedEntryCellViewModelDelegate

extension FavouriteEntriesSectionViewModel: FeedEntryCellViewModelDelegate {
    func readStatusChanged(isRead: Bool) { }

    func didSelect(cellViewModel: FeedEntryCellViewModel) {
//        selectedViewModel = cellViewModel
        print("activated")
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
            .map { cellViewModels[$0] }
            .compactMap { $0 as? FeedEntryCellViewModel }
            .forEach { $0.image = image }
    }
}
