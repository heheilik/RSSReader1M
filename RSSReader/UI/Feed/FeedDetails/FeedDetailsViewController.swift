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

    private var currentViewModel: FeedDetailsViewModel? {
        viewModel as? FeedDetailsViewModel
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

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Подробности"
    }

    // MARK: Internal methods

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
        guard let viewModel = currentViewModel else {
            fatalError("Wrong viewModel provided.")
        }
        feedImage.image = viewModel.context.image
        titleLabel.text = viewModel.context.title ?? ""
        descriptionLabel.text = viewModel.context.description ?? ""
        dateLabel.text = viewModel.context.date ?? ""

        view.layoutIfNeeded()

    }

}
