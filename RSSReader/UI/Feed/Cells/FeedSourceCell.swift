//
//  FeedSourceCell.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedSourceCell: FMTableViewCell {

    // MARK: UI

    private let nameLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // MARK: Private properties

    private weak var currentViewModel: FeedSourceCellViewModel? {
        return viewModel as? FeedSourceCellViewModel
    }

    // MARK: Internal methods

    override func addSubviews() {
        contentView.addSubview(nameLabel)
    }

    override func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(8)
            make.centerY.equalTo(contentView)
        }
    }

    override func fill(viewModel: FMCellViewModel) {
        super.fill(viewModel: viewModel)
        nameLabel.text = currentViewModel?.name
    }

}
