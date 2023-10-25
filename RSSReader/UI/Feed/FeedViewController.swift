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

        let dataSource = FMTableViewDataSource(
            viewModels: [FeedsSourcesListSection()],
            tableView: tableView
        )
        viewModel = FeedViewModel(
            sections: dataSource.sectionViewModels,
            dataSource: dataSource
        )

        self.dataSource = dataSource

        view.backgroundColor = .blue
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

