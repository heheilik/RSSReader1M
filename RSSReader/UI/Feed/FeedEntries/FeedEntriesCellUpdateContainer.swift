//
//  FeedEntriesCellUpdateContainer.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 15.02.24.
//

import Foundation

class FeedEntriesCellUpdateContainer {

    // MARK: Internal properties

    private(set) var cellViewModels: [(viewModel: FeedEntryCellViewModel, index: Int)] = []

    var ordered: [(viewModel: FeedEntryCellViewModel, index: Int)] {
        cellViewModels.sorted { $0.index < $1.index }
    }

    var indexSet: IndexSet {
        var set = IndexSet()
        cellViewModels.forEach {
            set.update(with: $0.index)
        }
        return set
    }

    // MARK: Internal methods

    func add(viewModel: FeedEntryCellViewModel, index: Int) {
        cellViewModels.append((viewModel: viewModel, index: index))
    }

    func removeAll() {
        cellViewModels = []
    }
}
