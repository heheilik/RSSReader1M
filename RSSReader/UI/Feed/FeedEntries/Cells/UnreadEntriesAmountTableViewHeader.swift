//
//  UnreadEntriesAmountTableViewHeader.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 5.02.24.
//

import FMArchitecture
import Foundation
import UIKit

class UnreadEntriesAmountTableViewHeader: FMHeaderFooterView {

    // MARK: Constants

    private enum Dimensions {
        static let inset = 16
        static let fontSize: CGFloat = 14
    }

    // MARK: UI

    private let titleLabel = UILabel()

    // MARK: Private properties

    private weak var currentViewModel: UnreadEntriesAmountHeaderViewModel? {
        viewModel as? UnreadEntriesAmountHeaderViewModel
    }

    // MARK: Lifecycle

    override func configureViews() {
        titleLabel.font = UIFont.systemFont(ofSize: Dimensions.fontSize)
        contentView.backgroundColor = .systemGray6
    }

    override func addSubviews() {
        contentView.addSubview(titleLabel)
    }

    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Dimensions.inset)
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
