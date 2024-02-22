//
//  FeedEntriesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FMArchitecture
import Foundation
import UIKit

final class FeedEntriesViewController: FMTablePageViewController {

    // MARK: UI

    private let refreshControl = UIRefreshControl()

    // MARK: Internal properties

    override var tableViewStyle: UITableView.Style {
        .plain
    }

    // MARK: Private properties

    private var currentViewModel: FeedEntriesViewModel? {
        viewModel as? FeedEntriesViewModel
    }

    // MARK: Lifecycle

    override func configureViews() {
        super.configureViews()
        refreshControl.addTarget(
            self,
            action: #selector(onRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource?.sectionViewModels.forEach {
            ($0 as? FMAnimatable)?.startAnimation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem { [weak self] in
            self?.dataSource?.sectionViewModels.forEach {
                ($0 as? FMAnimatable)?.stopAnimation()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentViewModel?.updateOnAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentViewModel?.saveFeedToCoreData()
    }

    // MARK: Private methods

    @objc
    private func onRefresh() {
        currentViewModel?.refresh()
    }
}

// MARK: - FeedEntriesViewModelDelegate

extension FeedEntriesViewController: FeedEntriesViewModelDelegate {
    func beginTableUpdates() {
        tableView.beginUpdates()
    }

    func endTableUpdates() {
        tableView.endUpdates()
    }

    func endRefresh() {
        refreshControl.endRefreshing()
    }
}
