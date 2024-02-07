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

    // MARK: Private properties

    private let sectionViewModel: FeedEntriesSectionViewModel

    // MARK: Initialization

    init(dataSource: FMDataManager, context: FeedEntriesContext) {
        sectionViewModel = FeedEntriesSectionViewModel(context: context)
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
    }

    // MARK: Internal methods

    func updateVisibleCellsViewModelsList(with viewModels: [FeedEntriesCellViewModel]) {
        sectionViewModel.updateVisibleCellsViewModelsList(with: viewModels)
    }
    
    func heightOfPresentedContent() -> CGFloat {
        return sectionViewModel.heightOfPresentedContent()
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedEntriesContext) {
        dataSource.update(with: [sectionViewModel])
    }
}
