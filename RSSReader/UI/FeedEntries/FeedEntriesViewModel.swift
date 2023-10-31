//
//  FeedEntriesViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FeedKit
import FMArchitecture
import Foundation

class FeedEntriesViewModel: FMTablePageViewModel {

    // MARK: Private properties

    private var sectionViewModels: [FMSectionViewModel] = []

    // MARK: Initialization

    init(dataSource: FMDataManager, context: FeedEntriesContext) {
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
        dataSource.update(with: sectionViewModels)
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedEntriesContext) {
        sectionViewModels = [
            FeedEntriesSectionViewModel(context: context)
        ]
    }

}
