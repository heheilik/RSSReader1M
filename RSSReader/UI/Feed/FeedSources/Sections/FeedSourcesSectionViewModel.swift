//
//  FeedSourcesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

class FeedSourcesSectionViewModel: FMSectionViewModel {

    private weak var currentDelegate: FeedSourcesSectionViewModelDelegate? {
        delegate as? FeedSourcesSectionViewModelDelegate
    }

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedSourceCell.self
    ]}

    // MARK: Initialization

    init(context: FeedSourcesContext, delegate: FeedSourcesSectionViewModelDelegate) {
        guard let delegate = delegate as? FMSectionViewModelDelegate else {
            fatalError("Wrong delegate provided.")
        }
        super.init(delegate: delegate)
        configureCellViewModels(with: context)
    }

    // MARK: Private methods

    private func configureCellViewModels(with context: FeedSourcesContext) {
        cellViewModels = context.data.map { feedSource in
            FeedSourceCellViewModel(
                name: feedSource.name,
                url: feedSource.url,
                delegate: self
            )
        }
    }

}

// MARK: - FeedSourceCellViewModelDelegate

extension FeedSourcesSectionViewModel: FeedSourceCellViewModelDelegate {
    
    func didSelect(cellWithUrl url: URL) {
        currentDelegate?.didSelect(cellWithUrl: url)
    }

}
