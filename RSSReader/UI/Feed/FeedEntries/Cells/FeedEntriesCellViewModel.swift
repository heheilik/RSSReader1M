//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import Combine
import Foundation
import FMArchitecture
import UIKit

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Internal properties

    let title: String?
    let description: String?
    let date: String?

    var descriptionShownFull = false
    
    @Published var isRead = false

    weak var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.fillableCell?.fill(viewModel: self)
            }
        }
    }

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
        super.init(
            cellIdentifier: FeedEntriesCell.cellIdentifier,
            delegate: delegate
        )
    }
}

// MARK: - FMSelectableCellModel

extension FeedEntriesCellViewModel: FMSelectableCellModel {
    func didSelect() {
        guard !isAnimation else {
            return
        }
        isRead = true
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

// MARK: - FMAnimatable

extension FeedEntriesCellViewModel: FMAnimatable {
    func startAnimation() {
        isAnimation = true
        fillableCell?.fill(viewModel: self)
        delegate?.didUpdate(cellViewModel: self)
    }

    func stopAnimation() {
        isAnimation = false
        fillableCell?.fill(viewModel: self)
        delegate?.didUpdate(cellViewModel: self)
    }
}
