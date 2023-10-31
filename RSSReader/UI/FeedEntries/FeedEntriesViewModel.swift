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
            tableView: nil  // FIXME: TableView must not be nil for cells to be registered
        )
        super.init(dataSource: dataSource)
    }

    // MARK: Internal methods
    
    /// This method updates dataSource with viewModels stored in this viewModel
    /// and registers cells provided by sectionViewModels.
    func updateDataSource() {
        dataSource.update(with: sectionViewModels)
    }

}
