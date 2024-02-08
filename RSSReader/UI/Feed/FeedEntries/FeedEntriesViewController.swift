//
//  FeedEntriesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedEntriesViewController: FMTablePageViewController {

    // MARK: Internal properties

    override var tableViewStyle: UITableView.Style {
        .plain
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        animateEntriesWithSkeleton()
    }

    // MARK: Private methods
    
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
}
