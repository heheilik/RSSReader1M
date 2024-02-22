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

final class FeedSourcesViewController: FMTablePageViewController {

    // MARK: Constants

    private enum Dimensions {
        static let progressAnimationWidthHeight = 256
    }

    private enum UIString {
        static let navigationBarTitle = "Источники"
        static let favouritesTitle = "Избранное"
    }

    // MARK: UI

    private let progressAnimation = LottieAnimationView(name: "loading")

    private lazy var favouritesBarButtonItem = UIBarButtonItem(
        title: UIString.favouritesTitle,
        style: .plain,
        target: self,
        action: #selector(favouritesBarButtonTouchUpInside)
    )

    // MARK: Private properties

    private var currentViewModel: FeedSourcesViewModel? {
        viewModel as? FeedSourcesViewModel
    }

    // MARK: Lifecycle

    override func configureViews() {
        view.backgroundColor = .white
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: Private properties

    private func configureNavigationBar() {
        navigationItem.title = UIString.navigationBarTitle
        navigationItem.rightBarButtonItem = favouritesBarButtonItem
    }

    @objc
    private func favouritesBarButtonTouchUpInside() {
        currentViewModel?.showFavouriteEntries()
    }
}

// MARK: - FeedUpdateDelegate

extension FeedSourcesViewController: FeedSourcesViewModelDelegate {
    func fetchStarted() {
        progressAnimation.isHidden = false
        progressAnimation.play()
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = false
        }
    }

    func fetchFinished(_ result: Result<Void, Error>) {
        progressAnimation.stop()
        progressAnimation.isHidden = true
        if let delegate = delegate as? FeedSourcesTableViewDelegate {
            delegate.cellsAreSelectable = true
        }
    }
}
