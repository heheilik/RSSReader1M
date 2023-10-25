//
//  FeedViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedViewModel: FMTablePageViewModel {

    // MARK: Private properties

    private var sections: [FMSectionViewModel]

    // MARK: Initialization

    convenience override init(dataSource: FMDataManager) {
        self.init(
            sections: dataSource.sectionViewModels,
            dataSource: dataSource
        )
    }

    init(
        sections: [FMSectionViewModel],
        dataSource: FMDataManager
    ) {
        self.sections = sections
        super.init(dataSource: dataSource)
    }

}
