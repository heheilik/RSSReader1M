//
//  FeedEntriesCell.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import Foundation
import FMArchitecture
import UIKit

class FeedEntriesCell: FMTableViewCell {

    private weak var currentViewModel: FeedEntriesCellViewModel? {
        return viewModel as? FeedEntriesCellViewModel
    }

    // MARK: UI

    private let titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let dateLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let descriptionSizeToggleButton = {
        let button = UIButton(type: .custom)
        button.setImage(chevronDownImage, for: .normal)
        return button
    }()

    private static let chevronUpImage = UIImage(systemName: "chevron.up")!
    private static let chevronDownImage = UIImage(systemName: "chevron.down")!

    private let feedImage = {
        let image = UIImageView()
        return image
    }()

    // MARK: Internal methods

    override func configureViews() {
        descriptionSizeToggleButton.addAction(UIAction { [weak self] _ in
            guard
                let self = self,
                let viewModel = self.currentViewModel
            else {
                return
            }
            viewModel.descriptionShownFull = !viewModel.descriptionShownFull
            self.resizeDescription(showFull: viewModel.descriptionShownFull, updateTable: true)
        }, for: .touchUpInside)
    }

    override func addSubviews() {
        contentView.addSubview(feedImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionSizeToggleButton)
        contentView.addSubview(dateLabel)
    }

    override func setupConstraints() {
        feedImage.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        feedImage.setContentHuggingPriority(.defaultLow + 1, for: .vertical)

        titleLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow + 2, for: .vertical)

        descriptionLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        descriptionLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)

        descriptionSizeToggleButton.setContentHuggingPriority(.defaultLow + 2, for: .horizontal)
        descriptionSizeToggleButton.setContentHuggingPriority(.defaultLow, for: .vertical)

        dateLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        dateLabel.setContentHuggingPriority(.defaultLow + 2, for: .vertical)

        feedImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(64)
            $0.height.equalTo(feedImage.snp.width)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(feedImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }
        descriptionSizeToggleButton.snp.makeConstraints {
            $0.centerY.equalTo(descriptionLabel)
            $0.leading.equalTo(descriptionLabel.snp.trailing).offset(8)
            $0.trailing.equalTo(titleLabel)
            $0.width.equalTo(32)
            $0.height.equalTo(descriptionSizeToggleButton.snp.width)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    override func fill(viewModel: FMCellViewModel) {
        super.fill(viewModel: viewModel)
        guard let viewModel = currentViewModel else {
            return
        }

        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description

        dateLabel.text = "[show date]"  // TODO: implement showing date

        resizeDescriptionIfNeeded()
    }

    // MARK: Private methods

    private func resizeDescription(showFull: Bool, updateTable: Bool) {
        guard let viewModel = currentViewModel else {
            return
        }

        let numberOfLines = showFull ? 3 : 1

        descriptionLabel.numberOfLines = numberOfLines
        descriptionSizeToggleButton.setImage(
            arrowImageFor(numberOfLines: numberOfLines),
            for: .normal
        )
        viewModel.descriptionShownFull = showFull

        if updateTable {
            viewModel.delegate?.didUpdate(cellViewModel: viewModel)
        }
    }

    private func resizeDescriptionIfNeeded() {
        guard let viewModel = currentViewModel else {
            return
        }
        let numberOfLines = viewModel.descriptionShownFull ? 3 : 1
        if descriptionLabel.numberOfLines != numberOfLines {
            resizeDescription(showFull: viewModel.descriptionShownFull, updateTable: false)
        }
    }

    private func arrowImageFor(numberOfLines: Int) -> UIImage {
        if numberOfLines == 1 {
            return FeedEntriesCell.chevronDownImage
        } else {
            return FeedEntriesCell.chevronUpImage
        }
    }

}
