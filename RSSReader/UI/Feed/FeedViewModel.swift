//
//  FeedViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedViewModel: FMTablePageViewModel {

    private var sections: [FMSectionViewModel]

    init(sections: [FMSectionViewModel], dataSource: FMDataManager) {
        self.sections = sections
        super.init(dataSource: dataSource)
    }

    private func configureSectionViewModels() {
        dataSource.merge(with: sections)
    }

}
