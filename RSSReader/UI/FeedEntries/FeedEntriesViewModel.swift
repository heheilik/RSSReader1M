//
//  FeedEntriesViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FeedKit
import FMArchitecture
import Foundation

class FeedEntriesViewModel: FMTablePageViewModel {

    // MARK: Private properties

    private var sectionViewModels: [FMSectionViewModel]

    // MARK: Initialization

    init(context: FeedEntriesContext) {
        sectionViewModels = [
            FeedEntriesSectionViewModel(context: context)
        ]
        let dataSource = FMTableViewDataSource(
            viewModels: sectionViewModels,
            tableView: nil
        )
        super.init(dataSource: dataSource)
    }

}
