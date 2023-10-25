//
//  FeedViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import UIKit

class FeedViewController: FMTablePageViewController {

    // MARK: Initialization

    override init() {
        super.init()
        viewModel = FMTablePageViewModel(
            dataSource: FMTableViewDataSource(
                tableView: tableView
            )
        )
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

}

