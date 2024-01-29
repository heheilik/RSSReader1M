//
//  FeedSourcesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import ALNavigation
import FMArchitecture
import Lottie
import UIKit

class FeedSourcesViewController: FMTablePageViewController {

    private var currentViewModel: FeedSourcesViewModel? {
        viewModel as? FeedSourcesViewModel
    }

    // MARK: UI

    private let progressAnimation = LottieAnimationView(name: "loader")

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Источники"
    }

    // MARK: Internal methods

    override func configureViews() {
        progressAnimation.loopMode = .loop
        progressAnimation.isHidden = true
        super.configureViews()
    }

    override func addSubviews() {
        super.addSubviews()
        view.addSubview(progressAnimation)
    }

    override func setupConstraints() {
        super.setupConstraints()
        progressAnimation.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
        }
    }

    // MARK: Private methods

    private func alertFor(error: DownloadError) -> UIAlertController {
        let alert = {
            let alert = UIAlertController(
                title: "",
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))
            return alert
        }()

        let representation = error.alertRepresentation()

        alert.title = representation.title
        alert.message = representation.message

        return alert
    }

}

// MARK: - FeedDownloadDelegate

extension FeedSourcesViewController: FeedDownloadDelegate {

    func downloadStarted() {
        progressAnimation.isHidden = false
        progressAnimation.play()
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = false
        }
    }

    func downloadCompleted(_ result: DownloadResult) {
        progressAnimation.stop()
        progressAnimation.isHidden = true
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = true
        }

        switch result {
        case let .success(feed):
            let feedName = currentViewModel?.lastClickedFeedName ?? "No name provided."
            Router.shared.push(
                FeedPageFactory.NavigationPath.feedEntries.rawValue,
                animated: true,
                context: FeedEntriesContext(
                    feedName: feedName,
                    rssFeed: feed
                )
            )
        case let .failure(error):
            present(alertFor(error: error), animated: true)
            return
        }
    }

}

// MARK: - DownloadError User-Friendly Representation

private extension DownloadError {

    func alertRepresentation() -> (title: String, message: String) {
        switch self {
        case .atomFeedDownloaded:
            return (title: "Atom feed is downloaded.", message: "This app can't parse Atom feeds.")
        case .jsonFeedDownloaded:
            return (title: "JSON feed is downloaded.", message: "This app can't parse JSON feeds.")
        case .feedNotDownloaded:
            return (title: "Could not download feed.", message: "Check connection and try again.")
        }
    }

}
