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

protocol FeedEntriesViewModelDelegate: AnyObject {
    func beginTableUpdates()
    func endTableUpdates()
}

class FeedEntriesViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    weak var delegate: FeedEntriesViewModelDelegate?

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

// MARK: - FeedEntriesSectionViewModelDelegate

extension FeedEntriesViewModel: FeedEntriesSectionViewModelDelegate {
    func beginTableUpdates() {
        delegate?.beginTableUpdates()
    }

    func endTableUpdates() {
        delegate?.endTableUpdates()
    }
}
