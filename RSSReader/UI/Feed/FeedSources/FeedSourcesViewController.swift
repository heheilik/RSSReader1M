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

    // MARK: Constants

    private enum Dimensions {
        static let progressAnimationWidthHeight = 256
    }

    // MARK: UI

    private let progressAnimation = LottieAnimationView(name: "loading")

    // MARK: Private properties

    private var currentViewModel: FeedSourcesViewModel? {
        viewModel as? FeedSourcesViewModel
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Источники"
    }

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
            make.height.width.equalTo(Dimensions.progressAnimationWidthHeight)
        }
    }

    // MARK: Private methods

    private func presentAlertFor(error: FeedUpdateManager.UpdateError, animated: Bool = true) {
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

        let representation = alertRepresentation(for: error)

        alert.title = representation.title
        alert.message = representation.message

        present(alert, animated: animated)
    }

    private func alertRepresentation(for error: FeedUpdateManager.UpdateError) -> (title: String, message: String) {
        switch error {
        case .feedNotDownloaded:
            return (title: "feedNotDownloaded", message: "")
        case .wrongFeedType:
            return (title: "wrongFeedType", message: "")
        case .parsingToManagedError:
            return (title: "parsingToManagedError", message: "")
        case .fetchError:
            return (title: "fetchError", message: "")
        case .saveError:
            return (title: "saveError", message: "")
        case .controllerUpdatingError:
            return (title: "controllerUpdatingError", message: "")
        }
    }
}

// MARK: - FeedUpdateDelegate

extension FeedSourcesViewController: FeedSourcesViewModelDelegate {
    func updateStarted() {
        progressAnimation.isHidden = false
        progressAnimation.play()
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = false
        }
    }

    func updateCompleted(withError error: FeedUpdateManager.UpdateError?) {
        progressAnimation.stop()
        progressAnimation.isHidden = true
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = true
        }
        if let error {
            presentAlertFor(error: error)
        }
    }
}
