//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture
import UIKit

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Internal properties

    let title: String?
    let description: String?
    let date: String?

    weak var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didUpdate(cellViewModel: self)
            }
        }
    }

    var descriptionShownFull = false

    // TODO: add read status

    // MARK: Initialization

    init(
        title: String?,
        description: String?,
        date: String?,
        delegate: FMCellViewModelDelegate
    ) {
        self.title = title
        self.description = description
        self.date = date
        super.init(cellIdentifier: FeedEntriesCell.cellIdentifier, delegate: delegate)
    }

    // MARK: Internal methods

    override func significantlyDifferent(from model: FMCellViewModel) -> Bool {
        guard let viewModel = model as? Self else {
            fatalError("Wrong viewModel.")
        }
        return descriptionShownFull != viewModel.descriptionShownFull
    }

}
