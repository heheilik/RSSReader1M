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
    func didSelect(cellViewModel: FeedEntriesCellViewModel)
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

    let managedObject: ManagedFeedEntry

    var descriptionShownFull = false
    
    @Published var isRead = false

    weak var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.fillableCell?.fill(viewModel: self)
            }
        }
    }

    var isFavourite: Bool {
        get {
            guard let context = managedObject.managedObjectContext else {
                assertionFailure("Object must exist in some context.")
                return false
            }
            var isFavourite = false
            context.performAndWait {
                isFavourite = managedObject.isFavourite
            }
            return isFavourite
        }
        set {
            guard let context = managedObject.managedObjectContext else {
                assertionFailure("Object must exist in some context.")
                return
            }
            context.performAndWait {
                managedObject.isFavourite = newValue
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
            (self.fillableCell as? FeedEntriesCell)?.changeFavouriteStatus(isFavourite: self.isFavourite)
        }
        favouriteAction.configure(
            with: isFavourite ? Images.starCrossed : Images.star,
            backgroundColor: .orange
        )

        return [readAction, favouriteAction]
    }

    // MARK: Private properties


    private var isReadSubscriber: AnyCancellable?

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
        var date: String?

        context.performAndWait {
            title = managedObject.title
            description = managedObject.entryDescription

            isRead = managedObject.isRead

            if let strongDate = managedObject.date {
                date = Self.dateFormatter.string(from: strongDate)
            } else {
                date = nil
            }
        }

        guard
            let title,
            let isRead
        else {
            assertionFailure("Title, read status and favourite status must be retrieved from model.")
            return nil
        }

        self.title = title
        self.description = description
        self.isRead = isRead
        self.date = date

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
}

// MARK: - FMSelectableCellModel

extension FeedEntriesCellViewModel: FMSelectableCellModel {
    func didSelect() {
        guard !isAnimation else {
            return
        }
        if isRead != true {
            isRead = true
        }
        currentDelegate?.didSelect(cellViewModel: self)
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
