//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import Combine
import CoreData
import Factory
import Foundation
import FMArchitecture
import SwipeCellKit
import UIKit

protocol FeedEntriesCellViewModelDelegate: AnyObject {
    func readStatusChanged(isRead: Bool)
}

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

    // MARK: Private properties

    private let managedObject: ManagedFeedEntry

    private var isReadSubscriber: AnyCancellable?

    @Injected(\.entryDateFormatter) private static var dateFormatter

    private weak var currentDelegate: FeedEntriesCellViewModelDelegate? {
        delegate as? FeedEntriesCellViewModelDelegate
    }

    // MARK: Initialization

    init(
        managedObject: ManagedFeedEntry,
        image: UIImage,
        delegate: FMCellViewModelDelegate,
        isAnimatedAtStart: Bool
    ) {
        self.managedObject = managedObject
        self.title = managedObject.title
        self.description = managedObject.entryDescription
        self.isRead = managedObject.isRead

        if let date = managedObject.date {
            self.date = Self.dateFormatter.string(from: date)
        } else {
            self.date = nil
        }

        self.image = image

        super.init(
            cellIdentifier: FeedEntriesCell.cellIdentifier,
            delegate: delegate
        )
        isAnimation = isAnimatedAtStart
        bindReadStatus()
    }

    // MARK: Internal methods

    override func isEqual(to viewModel: FMCellViewModel) -> Bool {
        guard let viewModel = viewModel as? FeedEntriesCellViewModel else {
            return false
        }
        return managedObject.objectID == viewModel.managedObject.objectID
    }

    // MARK: Private methods

    private func bindReadStatus() {
        isReadSubscriber = $isRead.sink { [weak self] newValue in
            if self?.managedObject.isRead != newValue {
                self?.managedObject.isRead = newValue
                self?.currentDelegate?.readStatusChanged(isRead: newValue)
            }
        }
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
