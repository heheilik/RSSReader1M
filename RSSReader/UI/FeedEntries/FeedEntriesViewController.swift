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

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
