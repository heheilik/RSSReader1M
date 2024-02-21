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
}

class FavouriteEntriesTableViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    weak var delegate: FavouriteEntriesTableViewModelDelegate?

    // MARK: Initialization

    init(
        context: FavouriteEntriesContext,
        dataSource: FMDataManager
    ) {
        super.init(dataSource: dataSource)
        configureSectionViewModels(context: context)
    }

    // MARK: Private methods

    private func configureSectionViewModels(context: FavouriteEntriesContext) {
        dataSource.update(with: [
            FavouriteEntriesSectionViewModel(context: context)
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
}
