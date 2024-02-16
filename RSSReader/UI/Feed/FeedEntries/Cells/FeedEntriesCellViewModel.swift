//
//  FeedEntriesCellViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Combine
import CoreData
import Factory
import Foundation
import FMArchitecture
import SwipeCellKit
import UIKit

protocol FeedEntriesCellViewModelDelegate: AnyObject {
    func readStatusChanged(isRead: Bool)
    func pushDetailsController(title: String, description: String?, date: String?, managedObject: NSManagedObject)
}

class FeedEntriesCellViewModel: FMCellViewModel {

    // MARK: Constants

    private enum UIStrings {
        static let isRead = "Прочитано"
        static let isUnread = "Непрочитано"
        static let makeFavourite = "Добавить в\nизбранное"
        static let makeNotFavourite = "Удалить из\nизбранного"
    }

    private enum Images {
        static let message = UIImage(systemName: "message")!
        static let messageWithBadge = UIImage(systemName: "message.badge")!
        static let star = UIImage(systemName: "star.fill")!
        static let starCrossed = UIImage(systemName: "star.slash.fill")!
    }

    // MARK: Internal properties

    let title: String
    let description: String?
    let date: String?

    var descriptionShownFull = false
    
    @Published var isRead = false
    @Published var isFavourite = false

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

        let readAction = SwipeAction(
            style: .default,
            title: isRead ? UIStrings.isUnread : UIStrings.isRead
        ) { [weak self] _, _ in
            guard let self = self else {
                return
            }
            self.isRead = !self.isRead
        }
        readAction.configure(
            with: isRead ? Images.messageWithBadge : Images.message,
            backgroundColor: .systemBlue
        )

        let favouriteAction = SwipeAction(
            style: .default,
            title: isFavourite ? UIStrings.makeNotFavourite : UIStrings.makeFavourite
        ) { [weak self ] _, _ in
            guard let self = self else {
                return
            }
            self.isFavourite = !self.isFavourite
        }
        favouriteAction.configure(
            with: isFavourite ? Images.starCrossed : Images.star,
            backgroundColor: .orange
        )

        return [readAction, favouriteAction]
    }

    // MARK: Private properties

    private let managedObject: ManagedFeedEntry

    private var isReadSubscriber: AnyCancellable?
    private var isFavouriteSubscriber: AnyCancellable?

    @Injected(\.entryDateFormatter) private static var dateFormatter

    private weak var currentDelegate: FeedEntriesCellViewModelDelegate? {
        delegate as? FeedEntriesCellViewModelDelegate
    }

    // MARK: Initialization
    
    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - managedObject: Managed object that represents current entry. Must exist in some context.
    ///   - image: Image of the source that this entry belongs to.
    ///   - delegate: View model delegate.
    ///   - isAnimatedAtStart: Defines whether skeleton animation is shown at start.
    ///
    /// Despite initializer is optional, `nil` mustn't be returned from here. Each case when `nil` is returned
    /// triggers an `assertionFailure(_:)`.
    init?(
        managedObject: ManagedFeedEntry,
        image: UIImage,
        delegate: FMCellViewModelDelegate,
        isAnimatedAtStart: Bool
    ) {
        self.managedObject = managedObject

        guard let context = managedObject.managedObjectContext else {
            assertionFailure("Managed object must exist in some context.")
            return nil
        }

        var title: String?
        var description: String?
        var isRead: Bool?
        var isFavourite: Bool?
        var date: String?

        context.performAndWait {
            title = managedObject.title
            description = managedObject.entryDescription

            isRead = managedObject.isRead
            isFavourite = managedObject.isFavourite

            if let strongDate = managedObject.date {
                date = Self.dateFormatter.string(from: strongDate)
            } else {
                date = nil
            }
        }

        guard
            let title,
            let isRead,
            let isFavourite
        else {
            assertionFailure("Title, read status and favourite status must be retrieved from model.")
            return nil
        }

        self.title = title
        self.description = description
        self.isRead = isRead
        self.isFavourite = isFavourite
        self.date = date

        self.image = image

        super.init(
            cellIdentifier: FeedEntriesCell.cellIdentifier,
            delegate: delegate
        )
        isAnimation = isAnimatedAtStart

        bindReadStatus()
        bindFavouriteStatus()
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
            guard
                let self = self,
                let context = self.managedObject.managedObjectContext
            else {
                return
            }
            context.performAndWait {
                if self.managedObject.isRead != newValue {
                    self.managedObject.isRead = newValue
                    self.currentDelegate?.readStatusChanged(isRead: newValue)
                }
            }
        }
    }

    private func bindFavouriteStatus() {
        isFavouriteSubscriber = $isFavourite.sink { [weak self] newValue in
            guard
                let self = self,
                let context = self.managedObject.managedObjectContext
            else {
                return
            }
            context.performAndWait {
                if newValue != self.managedObject.isFavourite {
                    self.managedObject.isFavourite = newValue
                }
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
        currentDelegate?.pushDetailsController(
            title: title,
            description: description,
            date: date,
            managedObject: managedObject
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
