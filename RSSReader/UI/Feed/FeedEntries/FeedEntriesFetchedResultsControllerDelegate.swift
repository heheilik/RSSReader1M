//
//  FeedEntriesFetchedResultsControllerDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 14.02.24.
//

import CoreData
import Foundation

class FeedEntriesFetchedResultsControllerDelegate: NSObject {
    weak var sectionViewModel: FeedEntriesSectionViewModel?
}

// MARK: - NSFetchedResultsControllerDelegate

extension FeedEntriesFetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.sectionViewModel?.fetchedResultsControllerWillChangeContent(controller)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.sectionViewModel?.fetchedResultsControllerDidChangeContent(controller)
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let object = anObject as? ManagedFeedEntry else {
            assertionFailure("This controller must work with ManagedFeedEntry objects only.", file: #file, line: #line)
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("This method must provide an indexPath.", file: #file, line: #line)
                return
            }
            DispatchQueue.main.async {
                self.sectionViewModel?.fetchedResultsController(
                    controller,
                    addedObject: object,
                    at: newIndexPath
                )
            }

        case .delete:
            guard let indexPath else {
                assertionFailure("This method must provide an indexPath.", file: #file, line: #line)
                return
            }
            DispatchQueue.main.async {
                self.sectionViewModel?.fetchedResultsController(
                    controller,
                    removedObject: object,
                    at: indexPath
                )
            }

        case .move:
            guard
                let oldIndexPath = indexPath,
                let newIndexPath
            else {
                assertionFailure("This method must provide an indexPath.", file: #file, line: #line)
                return
            }
            DispatchQueue.main.async {
                self.sectionViewModel?.fetchedResultsController(
                    controller,
                    movedObject: object,
                    from: oldIndexPath,
                    to: newIndexPath
                )
            }

        case .update:
            guard let indexPath else {
                assertionFailure("This method must provide an indexPath.", file: #file, line: #line)
                return
            }
            DispatchQueue.main.async {
                self.sectionViewModel?.fetchedResultsController(
                    controller,
                    updatedObject: object,
                    at: indexPath
                )
            }

        @unknown default:
            assertionFailure("Unexpected case.", file: #file, line: #line)
            return
        }
    }
}
