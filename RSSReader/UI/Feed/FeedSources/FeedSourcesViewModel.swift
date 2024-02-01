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

class FeedSourcesViewModel: FMTablePageViewModel {

    // MARK: Private properties

    private var sectionViewModels: [FMSectionViewModel] = []

    private var feedService: FeedService
    private weak var downloadDelegate: FeedUpdateDelegate?

    // MARK: Initialization

    init(
        context: FeedSourcesContext,
        dataSource: FMDataManager,
        downloadDelegate: FeedUpdateDelegate,
        feedService: FeedService = FeedService()
    ) {
        self.downloadDelegate = downloadDelegate
        self.feedService = feedService
        super.init(dataSource: dataSource)
        updateSectionViewModels(with: context)
        dataSource.update(with: sectionViewModels)
    }

    // MARK: Private methods

    private func updateSectionViewModels(with context: FeedSourcesContext) {
        sectionViewModels = [
            FeedSourcesSectionViewModel(
                context: context,
                delegate: self
            )
        ]
    }
}

// MARK: - FeedSourcesSectionViewModelDelegate

extension FeedSourcesViewModel: FeedSourcesSectionViewModelDelegate {
    func didSelect(cellWithData feedSource: FeedSource) {
        let feedUpdateManager = FeedUpdateManager(url: feedSource.url)
        downloadDelegate?.updateStarted()
        
        Task { [weak self] in
            guard let self = self else {
                return
            }

            await feedUpdateManager.update()
            guard feedUpdateManager.error == nil else {
                self.downloadDelegate?.updateCompleted(withError: nil)
                return
            }

            self.downloadDelegate?.updateCompleted(withError: nil)
            _ = await MainActor.run {
                Router.shared.push(
                    FeedPageFactory.NavigationPath.feedEntries.rawValue,
                    animated: true,
                    context: FeedEntriesContext(
                        feedName: feedSource.name,
                        feedPersistenceManager: feedUpdateManager.feedPersistenceManager
                    )
                )
            }
        }
    }
}
