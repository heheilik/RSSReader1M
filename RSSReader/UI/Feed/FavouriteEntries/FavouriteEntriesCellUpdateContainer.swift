//
//  FavouriteEntriesCellUpdateContainer.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 21.02.24.
//

import Foundation

final class FavouriteEntriesCellUpdateContainer {

    // MARK: Internal properties

    private(set) var deletedCellsIndices = IndexSet()
    private(set) var updatedManagedObjects: [(index: Int, managedObject: ManagedFeedEntry)] = []

    var updatedIndexSet: IndexSet {
        updatedManagedObjects.reduce(IndexSet()) { partialResult, object in
            var partialResult = partialResult
            partialResult.update(with: object.index)
            return partialResult
        }
    }

    // MARK: Internal methods

    func deleteCell(at index: Int) {
        deletedCellsIndices.insert(index)
    }

    func updateCell(at index: Int, with managedFeedEntry: ManagedFeedEntry) {
        updatedManagedObjects.append((index: index, managedObject: managedFeedEntry))
    }

    func reset() {
        deletedCellsIndices = IndexSet()
        updatedManagedObjects = []
    }
}
