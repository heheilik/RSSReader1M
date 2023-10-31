//
//  FeedViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import ALNavigation
import FMArchitecture
import UIKit

class FeedViewController: FMTablePageViewController {

    private var currentViewModel: FeedViewModel? {
        viewModel as? FeedViewModel
    }

    // MARK: UI

    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: Initialization

    init(sectionViewModels: [FeedSourcesSectionViewModel] = []) {
        super.init()

        let dataSource = FMTableViewDataSource(
            viewModels: sectionViewModels,
            tableView: tableView
        )
        viewModel = FeedViewModel(
            dataSource: dataSource,
            downloadDelegate: self
        )
        self.dataSource = dataSource
        self.delegate = FeedTableViewDelegate()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    // MARK: Internal methods

    override func addSubviews() {
        super.addSubviews()
        view.addSubview(activityIndicator)
    }

    override func setupConstraints() {
        super.setupConstraints()
        activityIndicator.snp.makeConstraints { make in
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

extension FeedViewController: FeedDownloadDelegate {

    func downloadStarted() {
        activityIndicator.startAnimating()
        if let delegate = delegate as? FeedTableViewDelegate {
            delegate.cellsAreSelectable = false
        }
    }

    func downloadCompleted(_ result: DownloadResult) {
        activityIndicator.stopAnimating()
        if let delegate = delegate as? FeedTableViewDelegate {
            delegate.cellsAreSelectable = true
        }

        switch result {
        case let .success(feed):
            Router.shared.present(
                FeedPageFactory.NavigationPath.feedEntries.rawValue,
                animated: true,
                with: FeedEntriesContext(rssFeed: feed)
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
