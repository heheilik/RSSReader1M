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

    init(sectionViewModels: [FeedsSourcesListSection] = []) {
        super.init()

        let dataSource = FMTableViewDataSource(
            viewModels: sectionViewModels,
            tableView: tableView
        )
        viewModel = FeedViewModel(dataSource: dataSource)
        self.dataSource = dataSource
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

}

