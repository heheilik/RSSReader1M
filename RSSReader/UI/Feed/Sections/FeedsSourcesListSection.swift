//
//  FeedsListSection.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedsSourcesListSection: FMSectionViewModel {

    private static let data: [(name: String, url: URL)] = [
        ( name: "Рамблер. В мире", url: URL(string: "https://news.rambler.ru/rss/world")! ),
        ( name: "Swift",           url: URL(string: "https://www.swift.org/atom.xml")!    ),
    ]

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {
        return [
            FeedSourceCell.self
        ]
    }

    // MARK: Initialization

    override init() {
        super.init()
        configureCellViewModels()
    }

    // MARK: Private methods

    private func configureCellViewModels() {
        let cellViewModels: [FeedSourceCellViewModel] = FeedsSourcesListSection.data.map {
            (name: String, _) in
            FeedSourceCellViewModel(name: name)
        }

        refresh(cellModels: cellViewModels)
    }

}
