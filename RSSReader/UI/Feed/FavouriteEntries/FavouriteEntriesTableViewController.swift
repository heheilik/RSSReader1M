//
//  FavouriteEntriesTableViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import FMArchitecture
import Foundation
import UIKit

final class FavouriteEntriesTableViewController: FMTablePageViewController {

    // MARK: Constants

    private enum UIString {
        static let navigationBarTitle = "Избранное"
        static let removeFromFavouriteAlertTitle = "Убрать из избранного"
        static let removeFromFavouriteAlertDescription = "Вы действительно хотите убрать новость из избранного?"
        static let removeFromFavouriteAlertDismiss = "Нет"
        static let removeFromFavouriteAlertConfirm = "Да"
    }

    // MARK: Internal properties

    override var tableViewStyle: UITableView.Style { .plain }

    // MARK: Private properties

    private var currentViewModel: FavouriteEntriesTableViewModel? {
        viewModel as? FavouriteEntriesTableViewModel
    }

    // MARK: Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentViewModel?.saveFeedToCoreData()
    }

    // MARK: Private methods

    private func configureNavigationBar() {
        navigationItem.title = UIString.navigationBarTitle
    }
}

// MARK: - FavouriteEntriesTableViewModelDelegate

extension FavouriteEntriesTableViewController: FavouriteEntriesTableViewModelDelegate {
    func beginTableUpdates() {
        tableView.beginUpdates()
    }

    func endTableUpdates() {
        tableView.endUpdates()
    }

    func cellViewModelActivatedFavouriteButton(_ cellViewModel: FeedEntryCellViewModel) {
        let alert = UIAlertController(
            title: UIString.removeFromFavouriteAlertTitle,
            message: UIString.removeFromFavouriteAlertDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: UIString.removeFromFavouriteAlertDismiss,
                style: .default
            ) { [weak alert] _ in
                alert?.dismiss(animated: true)
            }
        )
        alert.addAction(
            UIAlertAction(
                title: UIString.removeFromFavouriteAlertConfirm,
                style: .destructive
            ) { [weak self, weak alert] _ in
                self?.currentViewModel?.removeFromFavourites(cellViewModel: cellViewModel)
                alert?.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }
}
