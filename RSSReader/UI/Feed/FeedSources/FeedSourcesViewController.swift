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
    }
}
