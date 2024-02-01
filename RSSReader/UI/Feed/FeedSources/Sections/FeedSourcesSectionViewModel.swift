//
//  FeedSourcesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation

protocol FeedSourcesSectionViewModelDelegate: AnyObject {
    func didSelect(cellWithData feedSource: FeedSource)
}

class FeedSourcesSectionViewModel: FMSectionViewModel {

    // MARK: Internal properties

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedSourceCell.self
    ]}

    // MARK: Private properties

    private weak var currentDelegate: FeedSourcesSectionViewModelDelegate? {
        delegate as? FeedSourcesSectionViewModelDelegate
    }

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
        reload(cellModels: context.data.map { feedSource in
            FeedSourceCellViewModel(
                feedSource: feedSource,
                delegate: self
            )
        })
    }
}

// MARK: - FeedSourceCellViewModelDelegate

extension FeedSourcesSectionViewModel: FeedSourceCellViewModelDelegate {
    func didSelect(cellWithData feedSource: FeedSource) {
        currentDelegate?.didSelect(cellWithData: feedSource)
    }
}
