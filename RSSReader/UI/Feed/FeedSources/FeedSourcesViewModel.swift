//
//  FeedSourcesViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import ALNavigation
import FMArchitecture
import Foundation
import FeedKit

protocol FeedSourcesViewModelDelegate: AnyObject {
    func fetchStarted()
    func fetchFinished(_ result: Result<Void, Error>)
}

final class FeedSourcesViewModel: FMTablePageViewModel {

    // MARK: Private properties

    private var feedService: FeedService

    private weak var delegate: FeedSourcesViewModelDelegate?

    // MARK: Initialization

    init(
        context: FeedSourcesContext,
        dataSource: FMDataManager,
        delegate: FeedSourcesViewModelDelegate,
        feedService: FeedService = FeedService()
    ) {
        self.delegate = delegate
        self.feedService = feedService
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
    }

    // MARK: Internal methods

    func showFavouriteEntries() {
        delegate?.fetchStarted()
        Task {
            let persistenceManager = FavouriteEntriesPersistenceManager()
            await persistenceManager.fetchControllerData()
            await MainActor.run {
                delegate?.fetchFinished(.success)
                Router.shared.push(
                    FeedPageFactory.NavigationPath.favouriteEntries.rawValue,
                    animated: true,
                    context: FavouriteEntriesContext(persistenceManager: persistenceManager)
                )
            }
        }
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedSourcesContext) {
        dataSource.update(with: [
            FeedSourcesSectionViewModel(
                context: context,
                delegate: self
            )
        ])
    }
}

// MARK: - FeedSourcesSectionViewModelDelegate

extension FeedSourcesViewModel: FeedSourcesSectionViewModelDelegate {
    func didSelect(cellWithData feedSource: FeedSource) {
        delegate?.fetchStarted()
        Task {
            let persistenceManager = SingleFeedPersistenceManager(url: feedSource.url)
            await persistenceManager.fetchControllerData()
            guard let unreadEntriesCount = await persistenceManager.fetchUnreadEntriesCount(for: feedSource.url) else {
                assertionFailure("No problems must happen here.")
                return
            }

            // TODO: add error handling
            await MainActor.run {
                delegate?.fetchFinished(.success)
                Router.shared.push(
                    FeedPageFactory.NavigationPath.feedEntries.rawValue,
                    animated: true,
                    context: FeedEntriesContext(
                        feedName: feedSource.name,
                        feedPersistenceManager: persistenceManager,
                        unreadEntriesCount: unreadEntriesCount
                    )
                )
            }
        }
    }
}
