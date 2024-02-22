//
//  FeedEntriesCellUpdateContainer.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 15.02.24.
//

import Foundation

final class FeedEntriesCellUpdateContainer {

    // MARK: Internal properties

    private(set) var cellViewModels: [(index: Int, viewModel: FeedEntryCellViewModel)] = []

    var ordered: [(index: Int, viewModel: FeedEntryCellViewModel)] {
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

    func add(index: Int, viewModel: FeedEntryCellViewModel) {
        cellViewModels.append((index: index, viewModel: viewModel))
    }

    func removeAll() {
        cellViewModels = []
    }
}
