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
import SwipeCellKit
import UIKit

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Constants

    private enum UIStrings {
        static let isRead = "Прочитано"
        static let isUnread = "Непрочитано"
    }

    private enum Images {
        static let message = UIImage(systemName: "message")!
        static let messageWithBadge = UIImage(systemName: "message.badge")!
    }

    // MARK: Internal properties

    let title: String?
    let description: String?
    let date: String?

    let orderID: Int64

    var descriptionShownFull = false
    
    @Published var isRead = false

    weak var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.fillableCell?.fill(viewModel: self)
            }
        }
    }

    override var rightSwipeAction: [SwipeAction]? {
        guard !isAnimation else {
            return nil
        }

        let action = SwipeAction(
            style: .default,
            title: isRead ? UIStrings.isUnread : UIStrings.isRead
        ) { [weak self] _, _ in
            guard let self = self else {
                return
            }
            self.isRead = !self.isRead
        }
        action.configure(
            with: isRead ? Images.messageWithBadge : Images.message,
            backgroundColor: .systemBlue
        )
        return [action]
    }

    // MARK: Initialization

    init(
        title: String?,
        description: String?,
        date: String?,
        orderID: Int64,
        image: UIImage,
        delegate: FMCellViewModelDelegate,
        isAnimatedAtStart: Bool
    ) {
        self.title = title
        self.description = description
        self.date = date
        self.orderID = orderID
        self.image = image
        super.init(
            cellIdentifier: FeedEntriesCell.cellIdentifier,
            delegate: delegate
        )
        isAnimation = isAnimatedAtStart
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
