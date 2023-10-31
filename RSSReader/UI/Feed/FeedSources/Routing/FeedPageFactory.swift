//
//  FeedPageFactory.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import FMArchitecture
import Foundation
import UIKit

struct FeedPageFactory: PageFactoryProtocol {

    enum NavigationPath: String, CaseIterable {
        case feedSources = "/feedSources"
        case feedEntries = "/feedEntries"
    }

    // MARK: Internal methods

    func controller(for path: String, with context: PageContext?) throws -> UIViewController {
        guard let typedPath = NavigationPath(rawValue: path) else {
            throw PageFactoryErrorType.NavigationPathNotHandled
        }
        switch typedPath {
        case .feedSources:
            fatalError("Not implemented.", file: #file, line: #line)

        case .feedEntries:
            guard let context = context as? FeedEntriesContext else {
                fatalError("Context must be supplied for FeedEntriesViewController.")
            }
            return newFeedEntriesViewController(context: context)
        }
    }

    private func newFeedSourcesViewController(context: FeedSourcesContext) -> FeedsourcesViewController {

    }

    private func newFeedEntriesViewController(context: FeedEntriesContext) -> FeedEntriesViewController {
        let viewController = FeedEntriesViewController()

        let dataSource = FMTableViewDataSource(
            tableView: viewController.tableView
        )
        viewController.dataSource = dataSource

        let viewModel = FeedEntriesViewModel(
            dataSource: dataSource,
            context: context
        )
        viewController.viewModel = viewModel

        return viewController
    }

}
