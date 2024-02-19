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

    // MARK: Constants

    enum NavigationPath: String, CaseIterable {
        case favouriteEntries = "/favouriteEntries"
        case feedDetails = "/feedDetails"
        case feedEntries = "/feedEntries"
        case feedSources = "/feedSources"
    }

    // MARK: Internal methods

    func controller(for path: String, with context: PageContext?) throws -> UIViewController {
        guard let typedPath = NavigationPath(rawValue: path) else {
            throw PageFactoryErrorType.NavigationPathNotHandled
        }
        switch typedPath {
        case .favouriteEntries:
            guard let context = context as? FavouriteEntriesContext else {
                fatalError("Context must be supplied for FavouriteEntriesTableViewController.")
            }
            return newFavouriteEntriesTableViewController(context: context)

        case .feedDetails:
            guard let context = context as? FeedDetailsContext else {
                fatalError("Context must be supplied for FeedEntriesViewController.")
            }
            return newFeedDetailsViewController(context: context)

        case .feedEntries:
            guard let context = context as? FeedEntriesContext else {
                fatalError("Context must be supplied for FeedEntriesViewController.")
            }
            return newFeedEntriesViewController(context: context)

        case .feedSources:
            guard let context = context as? FeedSourcesContext else {
                fatalError("Context must be supplied for FeedEntriesViewController.")
            }
            return newFeedSourcesViewController(context: context)
        }
    }

    // MARK: Private methods

    private func newFavouriteEntriesTableViewController(
        context: FavouriteEntriesContext
    ) -> FavouriteEntriesTableViewController {
        fatalError("Not implemented.", file: #file, line: #line)
    }

    private func newFeedDetailsViewController(context: FeedDetailsContext) -> FeedDetailsViewController {
        let viewController = FeedDetailsViewController()
        let viewModel = FeedDetailsViewModel(context: context)

        viewController.viewModel = viewModel
        return viewController
    }

    private func newFeedEntriesViewController(context: FeedEntriesContext) -> FeedEntriesViewController {
        let viewController = FeedEntriesViewController()
        viewController.delegate = FMTableViewDelegate()

        let dataSource = FMTableViewDataSource(
            tableView: viewController.tableView
        )
        viewController.dataSource = dataSource

        let viewModel = FeedEntriesViewModel(
            dataSource: dataSource,
            context: context
        )
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        viewController.navigationItem.title = context.feedName
        return viewController
    }

    private func newFeedSourcesViewController(context: FeedSourcesContext) -> FeedSourcesViewController {
        let viewController = FeedSourcesViewController()
        viewController.delegate = FeedSourcesTableViewDelegate()

        let dataSource = FMTableViewDataSource(
            tableView: viewController.tableView
        )
        viewController.dataSource = dataSource

        let viewModel = FeedSourcesViewModel(
            context: context,
            dataSource: dataSource,
            delegate: viewController
        )
        viewController.viewModel = viewModel

        return viewController
    }
}
