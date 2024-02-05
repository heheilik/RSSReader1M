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
    func updateStarted()
    func updateCompleted(withError error: FeedUpdateManager.UpdateError?)
}

class FeedSourcesViewModel: FMTablePageViewModel {

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
        let feedUpdateManager = FeedUpdateManager(url: feedSource.url)
        delegate?.updateStarted()

        Task { [weak self] in
            guard let self = self else {
                return
            }

            await feedUpdateManager.update()
            guard feedUpdateManager.error == nil else {
                _ = await MainActor.run {
                    self.delegate?.updateCompleted(withError: feedUpdateManager.error)
                }
                return
            }

            _ = await MainActor.run {
                self.delegate?.updateCompleted(withError: nil)
                guard
                    let greatestOrderID = feedUpdateManager.greatestOrderID,
                    let lastReadOrderID = feedUpdateManager.lastReadOrderID
                else {
                    return
                }
                Router.shared.push(
                    FeedPageFactory.NavigationPath.feedEntries.rawValue,
                    animated: true,
                    context: FeedEntriesContext(
                        feedName: feedSource.name,
                        feedPersistenceManager: feedUpdateManager.feedPersistenceManager,
                        lastReadOrderID: lastReadOrderID
                    )
                )
            }
        }
    }
}
