//
//  UnseenEntriesAmountTableViewHeader.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 5.02.24.
//

import FMArchitecture
import Foundation
import UIKit

class UnseenEntriesAmountTableViewHeader: FMHeaderFooterView {

    // MARK: Constants

    private enum Dimensions {
        static let horizontalInset = 8
        static let verticalInset = 16
        static let fontSize: CGFloat = 14
    }

    // MARK: UI

    private let titleLabel = UILabel()

    // MARK: Private properties

    private weak var currentViewModel: UnseenEntriesAmountHeaderViewModel? {
        viewModel as? UnseenEntriesAmountHeaderViewModel
    }

    // MARK: Lifecycle

    override func configureViews() {
        titleLabel.font = UIFont.systemFont(ofSize: Dimensions.fontSize)
        contentView.backgroundColor = .systemGray5
    }

    override func addSubviews() {
        contentView.addSubview(titleLabel)
    }

    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Dimensions.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(Dimensions.verticalInset)
        }
    }

    override func fill(viewModel: FMHeaderFooterViewModel) {
        super.fill(viewModel: viewModel)
        guard let currentViewModel else {
            return
        }
        titleLabel.text = currentViewModel.text
    }
}
