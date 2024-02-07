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

    private let initialLastSeenOrderID: Int64

    private var currentViewModel: FeedEntriesViewModel? {
        viewModel as? FeedEntriesViewModel
    }

    // MARK: Initialization

    init(context: FeedEntriesContext) {
        initialLastSeenOrderID = context.lastReadOrderID
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        animateEntriesWithSkeleton()
        scrollTableToLastSeenEntry()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTableContentInset()
        scrollTableToLastSeenEntry()
    }

    // MARK: Private methods
    
    /// Scrolls tableView to starting position so it will load only necessary views.
    ///
    /// This method must be called in ``viewDidLoad()``, so it scrolls table before it loads views. This way it won't
    /// load views that it doesn't need (e. g. views at first indices) and will load views that it needs (last ones,
    /// if all content of feed wasn't seen by the user before).
    ///
    private func scrollTableToLastSeenEntry() {
        
    }
    
    /// Sets initial content inset for table view.
    ///
    /// It's needed when all or almost all content of feed is new to user, and table needs to show only
    /// one or two feed entries.
    ///
    /// Must be called in ``viewWillAppear(_:)`` or later.
    ///
    /// `scrollTableToLastSeenEntry()` must be called after this method, because when content is set, content
    /// must be scrolled more presicely.
    ///
    private func setTableContentInset() {

    }
    
    private func animateEntriesWithSkeleton() {
        dataSource?.sectionViewModels.forEach {
            ($0 as? FMAnimatable)?.startAnimation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem { [weak self] in
            self?.dataSource?.sectionViewModels.forEach {
                ($0 as? FMAnimatable)?.stopAnimation()
            }
        })
    }

    private func setStartingTableViewContentInset() {
        print(tableView.frame)
        guard let contentHeight = currentViewModel?.heightOfPresentedContent() else {
            return
        }
        print(tableView.bounds.height, contentHeight)
        tableView.contentInset.bottom = tableView.bounds.height - contentHeight
        tableView.insetsContentViewsToSafeArea = false
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
