//
//  FeedEntriesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FMArchitecture
import Foundation
import UIKit

protocol FeedEntriesScrollDelegate: AnyObject {
    func visibleCellsIndexPathsUpdated(at indexPaths: [IndexPath])
}

class FeedEntriesViewController: FMTablePageViewController {

    // MARK: Internal properties

    override var tableViewStyle: UITableView.Style {
        .plain
    }

    // MARK: Private properties

    private var currentViewModel: FeedEntriesViewModel? {
        viewModel as? FeedEntriesViewModel
    }

    // MARK: Lifecycle

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
}

// MARK: - FeedEntriesScrollDelegate

extension FeedEntriesViewController: FeedEntriesScrollDelegate {
    func visibleCellsIndexPathsUpdated(at indexPaths: [IndexPath]) {
        let cellViewModels = indexPaths.compactMap {
            (tableView.cellForRow(at: $0) as? FeedEntriesCell)?.viewModel as? FeedEntriesCellViewModel
        }
        currentViewModel?.updateVisibleCellsViewModelsList(with: cellViewModels)
    }
}
