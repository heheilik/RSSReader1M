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

    private var currentViewModel: FeedEntriesViewModel? {
        return viewModel as? FeedEntriesViewModel
    }

    // MARK: Initialization

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
