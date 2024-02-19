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
    func endRefresh()
}

class FeedEntriesViewModel: FMTablePageViewModel {

    // MARK: Internal properties

    weak var delegate: FeedEntriesViewModelDelegate?

    // MARK: Private properties

    private var feedEntriesSectionViewModels: [FeedEntriesSectionViewModel] {
        dataSource.sectionViewModels.compactMap { $0 as? FeedEntriesSectionViewModel }
    }

    // MARK: Initialization

    init(dataSource: FMDataManager, context: FeedEntriesContext) {
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
    }

    // MARK: Internal methods

    func saveFeedToCoreData() {
        feedEntriesSectionViewModels.forEach { sectionViewModel in
            Task {
                await sectionViewModel.saveFeedToCoreData()
            }
        }
    }

    func refresh() {
        feedEntriesSectionViewModels.forEach { sectionViewModel in
            Task {
                await sectionViewModel.updateFeed()
                async let _ = MainActor.run {
                    delegate?.endRefresh()
                }
            }
        }
    }

    func updateOnAppear() {
        feedEntriesSectionViewModels.forEach { $0.updateOnAppear() }
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
