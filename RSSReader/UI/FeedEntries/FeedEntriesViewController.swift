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

        guard let dataSource = currentViewModel?.dataSource as? FMTableViewDataSource else {
            fatalError("Data Source is not initialized.")
        }
        dataSource.tableView = tableView
        self.dataSource = dataSource
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
