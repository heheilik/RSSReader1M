//
//  FavouriteEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

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
    private let feedImageService: FeedImageService

    // MARK: Initialization

    init(
        context: FavouriteEntriesContext,
        feedImageService: FeedImageService = FeedImageService()
    ) {
        self.persistenceManager = context.persistenceManager
        self.feedImageService = feedImageService
        super.init()
        configureCellViewModels()
    }

    // MARK: Private methods

    private func configureCellViewModels() {
        guard let managedFeedEntries = persistenceManager.fetchedResultsController.fetchedObjects else {
            return
        }
        reload(cellModels: managedFeedEntries.compactMap { [weak self] entry in
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
    }
}
