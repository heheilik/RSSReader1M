//
//  FeedEntriesCellUpdater.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 15.02.24.
//

import Foundation

class FeedEntriesCellUpdater {

    // MARK: Internal properties

    private(set) var cellViewModels: [(viewModel: FeedEntriesCellViewModel, index: Int)] = []

    var ordered: [(viewModel: FeedEntriesCellViewModel, index: Int)] {
        cellViewModels.sorted { $0.1 < $1.1 }
    }

    var indexSet: IndexSet {
        var set = IndexSet()
        cellViewModels.forEach {
            set.update(with: $0.1)
        }
        print(set)
        return set
    }

    // MARK: Internal methods

    func add(viewModel: FeedEntriesCellViewModel, index: Int) {
        cellViewModels.append((viewModel: viewModel, index: index))
    }

    func reset() {
        cellViewModels = []
    }
}
