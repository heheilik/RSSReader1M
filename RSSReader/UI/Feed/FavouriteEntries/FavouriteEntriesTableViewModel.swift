//
//  FavouriteEntriesTableViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import FMArchitecture
import Foundation

class FavouriteEntriesTableViewModel: FMTablePageViewModel {

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
