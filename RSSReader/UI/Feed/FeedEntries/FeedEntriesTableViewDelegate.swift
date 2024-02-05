//
//  FeedEntriesTableViewDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 5.02.24.
//

import FMArchitecture
import Foundation
import UIKit

class FeedEntriesTableViewDelegate: FMTableViewDelegate {

    weak var feedEntriesScrollDelegate: (any FeedEntriesScrollDelegate)?

    // MARK: Internal methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else {
            return
        }
        feedEntriesScrollDelegate?.visibleCellsIndexPathsUpdated(at: tableView.indexPathsForVisibleRows ?? [])
    }
}
