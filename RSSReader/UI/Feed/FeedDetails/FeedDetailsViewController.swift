//
//  FeedDetailsViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedDetailsViewController: FMPageViewController {

    // MARK: Constants

    private enum UIString {
        static let navigationBarTitle = "Подробности"
    }

    private enum Image {
        static let star = UIImage(systemName: "star")!.withTintColor(.black).withRenderingMode(.alwaysOriginal)
        static let starFill = UIImage(systemName: "star.fill")!.withTintColor(.orange).withRenderingMode(.alwaysOriginal)
    }

    // MARK: UI

    private let feedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        return label
    }()

    private lazy var favouriteBarButton = UIBarButtonItem(
        image: Image.star,
        style: .plain,
        target: self,
        action: #selector(favouriteButtonTouchUpInside)
    )

    // MARK: Private properties

    private var currentViewModel: FeedDetailsViewModel? {
        viewModel as? FeedDetailsViewModel
    }

    // MARK: Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentViewModel?.saveToDatabase()
    }

    override func addSubviews() {
        view.addSubview(feedImage)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(dateLabel)
    }

    override func setupConstraints() {
        feedImage.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(200)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(feedImage.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }
    }

    override func bind() {
        guard let currentViewModel else {
            assertionFailure("Wrong viewModel provided.")
            return
        }

        titleLabel.text = currentViewModel.title
        descriptionLabel.text = currentViewModel.entryDescription ?? ""
        dateLabel.text = currentViewModel.date ?? ""
        feedImage.image = currentViewModel.image

        favouriteBarButton.image = currentViewModel.isFavourite ? Image.starFill : Image.star

        view.layoutIfNeeded()
    }

    // MARK: Private methods

    private func configureNavigationBar() {
        navigationItem.title = UIString.navigationBarTitle
        navigationItem.rightBarButtonItem = favouriteBarButton
    }

    @objc
    private func favouriteButtonTouchUpInside() {
        guard let currentViewModel else {
            return
        }
        currentViewModel.isFavourite = !currentViewModel.isFavourite
        favouriteBarButton.image = currentViewModel.isFavourite ? Image.starFill : Image.star
    }
}
