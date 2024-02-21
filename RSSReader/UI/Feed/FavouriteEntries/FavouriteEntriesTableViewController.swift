//
//  FavouriteEntriesTableViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 19.02.24.
//

import FMArchitecture
import Foundation
import UIKit

class FavouriteEntriesTableViewController: FMTablePageViewController {

    // MARK: Constants

    private enum UIString {
        static let navigationBarTitle = "Избранное"
    }

    // MARK: Internal properties

    override var tableViewStyle: UITableView.Style { .plain }

    // MARK: Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
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
}
