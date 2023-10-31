//
//  FeedSourcesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

protocol FeedSourcesSectionViewModelDelegate {

    func didSelect(cellWithUrl url: URL)

}

class FeedSourcesSectionViewModel: FMSectionViewModel {

    private static let data: [(name: String, url: URL)] = [
        ( name: "Рамблер. В мире", url: URL(string: "https://news.rambler.ru/rss/world")! ),
        ( name: "Swift",           url: URL(string: "https://www.swift.org/atom.xml")!    ),
    ]

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {
        return [
            FeedSourceCell.self
        ]
    }

    // MARK: Private properties

    private var currentDelegate: FeedSourcesSectionViewModelDelegate? {
        delegate as? FeedSourcesSectionViewModelDelegate
    }

    // MARK: Initialization

    override init() {
        super.init()
        configureCellViewModels()
    }

    // MARK: Private methods

    private func configureCellViewModels() {
        let cellViewModels: [FeedSourceCellViewModel] = FeedSourcesSectionViewModel.data.map {
            (name: String, url: URL) in
            FeedSourceCellViewModel(
                name: name,
                url: url,
                delegate: self
            )
        }

        refresh(cellModels: cellViewModels)
    }

}

// MARK: - FeedSourceCellViewModelDelegate

extension FeedSourcesSectionViewModel: FeedSourceCellViewModelDelegate {
    
    func didSelect(cellWithUrl url: URL) {
        currentDelegate?.didSelect(cellWithUrl: url)
    }

}
