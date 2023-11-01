//
//  FeedEntriesSectionViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture
import UIKit

class FeedEntriesSectionViewModel: FMSectionViewModel {

    override var registeredCellTypes: [FMTableViewCellProtocol.Type] {[
        FeedEntriesCell.self
    ]}

    // MARK: Internal properties

    private(set) var image: UIImage?

    // MARK: Private properties

    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    // MARK: Initialization

    init(context: FeedEntriesContext) {
        super.init()
        downloadImageIfPossible(urlString: context.rssFeed.image?.url)
        configureCellViewModels(context: context)
    }

    // MARK: Private methods

    private func configureCellViewModels(context: FeedEntriesContext) {
        guard let feedItems = context.rssFeed.items else {
            cellViewModels = []
            return
        }
        cellViewModels = feedItems.map({ item in
            let date: String?
            if let typedDate = item.pubDate {
                date = dateFormatter.string(from: typedDate)
            } else {
                date = nil
            }
            return FeedEntriesCellViewModel(
                title: item.title,
                description: item.description,
                date: date,
                delegate: self
            )
        })
    }

    private func downloadImageIfPossible(urlString: String?) {
        guard
            let urlString,
            let url = URL(string: urlString)
        else {
            print(urlString)
            return
        }
        print(urlString)  // TODO: Connect urls

        let service = FeedImageService()
        service.prepareImage(at: url) { image in
            guard let image else {
                return
            }
            self.image = image
        }
    }

}
