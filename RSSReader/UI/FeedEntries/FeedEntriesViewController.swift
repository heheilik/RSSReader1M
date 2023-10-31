//
//  FeedEntriesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FMArchitecture
import Foundation
import FeedKit

class FeedEntriesViewController: FMTablePageViewController {

    // MARK: Private properties

    private var currentViewModel: FeedEntriesViewModel? {
        return viewModel as? FeedEntriesViewModel
    }

    // MARK: Initialization

    init(context: FeedEntriesContext) {
        super.init()
        viewModel = FeedEntriesViewModel(context: context)
        connectDataSourceToTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Private methods

    private func connectDataSourceToTableView() {
        guard
            let viewModel = currentViewModel,
            let dataSource = viewModel.dataSource as? FMTableViewDataSource
        else {
            fatalError("ViewModel or DataSource type is not correct.")
        }
        dataSource.tableView = tableView
        self.dataSource = dataSource
        viewModel.updateDataSource()
    }

}
