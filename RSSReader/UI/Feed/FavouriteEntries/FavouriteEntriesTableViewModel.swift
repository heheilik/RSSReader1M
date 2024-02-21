//
//  FavouriteEntriesTableViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import FMArchitecture
import Foundation

protocol FavouriteEntriesTableViewModelDelegate: AnyObject {
    func beginTableUpdates()
    func endTableUpdates()
    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel)
}

class FavouriteEntriesTableViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    weak var delegate: FavouriteEntriesTableViewModelDelegate?

    // MARK: Private properties

    private var favouriteEntriesSectionViewModels: [FavouriteEntriesSectionViewModel] {
        dataSource.sectionViewModels.compactMap { $0 as? FavouriteEntriesSectionViewModel }
    }

    // MARK: Initialization

    init(
        context: FavouriteEntriesContext,
        dataSource: FMDataManager
    ) {
        super.init(dataSource: dataSource)
        configureSectionViewModels(context: context)
    }

    // MARK: Internal methods

    func saveFeedToCoreData() {
        favouriteEntriesSectionViewModels.forEach { sectionViewModel in
            Task {
                await sectionViewModel.saveFeedToCoreData()
            }
        }
    }

    func removeFromFavourites(cellViewModel: FeedEntryCellViewModel) {
        favouriteEntriesSectionViewModels.forEach { sectionViewModel in
            sectionViewModel.removeFromFavourites(cellViewModel: cellViewModel)
        }
    }

    // MARK: Private methods

    private func configureSectionViewModels(context: FavouriteEntriesContext) {
        dataSource.update(with: [
            FavouriteEntriesSectionViewModel(context: context, delegate: self)
        ])
    }
}

// MARK: - FavouriteEntriesSectionViewModelDelegate

extension FavouriteEntriesTableViewModel: FavouriteEntriesSectionViewModelDelegate {
    func beginTableUpdates() {
        delegate?.beginTableUpdates()
    }

    func endTableUpdates() {
        delegate?.endTableUpdates()
    }

    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel) {
        delegate?.cellViewModelActivatedFavouriteButton(cellViewModel)
    }
}
