//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
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
        image: UIImage,
        delegate: FMCellViewModelDelegate
    ) {
        self.title = title
        self.description = description
        self.date = date
        self.image = image
        super.init(cellIdentifier: FeedEntriesCell.cellIdentifier, delegate: delegate)
    }

    // MARK: Internal methods

    // TODO: Remove
    override func significantlyDifferent(from model: FMCellViewModel) -> Bool {
        guard let viewModel = model as? Self else {
            fatalError("Wrong viewModel.")
        }
        return
            descriptionShownFull != viewModel.descriptionShownFull ||
            image != viewModel.image
    }

}

extension FeedEntriesCellViewModel: FMSelectableCellModel {

    func didSelect() {
        Router.shared.push(
            FeedPageFactory.NavigationPath.feedDetails.rawValue,
            animated: true,
            context: FeedDetailsContext(
                title: title,
                description: description,
                date: date,
                image: image
            )
        )
    }

}

