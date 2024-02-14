//
//  FeedEntriesViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FeedKit
import FMArchitecture
import Foundation
import SkeletonView

class FeedEntriesViewModel: FMTablePageViewModel {

    // MARK: Initialization

    init(dataSource: FMDataManager, context: FeedEntriesContext) {
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
    }

    // MARK: Internal methods

    func saveFeedToCoreData() {
        dataSource.sectionViewModels
            .compactMap {
                $0 as? FeedEntriesSectionViewModel
            }
            .forEach { sectionViewModel in
                Task {
                    await sectionViewModel.saveFeedToCoreData()
                }
            }
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedEntriesContext) {
        dataSource.update(with: [
            FeedEntriesSectionViewModel(context: context)
        ])
    }
}
