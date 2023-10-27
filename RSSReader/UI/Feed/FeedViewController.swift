//
//  FeedViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import FMArchitecture
import UIKit

class FeedViewController: FMTablePageViewController {

    // MARK: UI

    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: Private properties

    private var currentViewModel: FeedViewModel? {
        viewModel as? FeedViewModel
    }

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

}

extension FeedViewController: FeedDownloadDelegate {

    func downloadStarted() {
        activityIndicator.startAnimating()
        if let delegate = delegate as? FeedTableViewDelegate {
            delegate.cellsAreSelectable = false
        }
    }

    func downloadCompleted(didSucceed: Bool) {
        activityIndicator.stopAnimating()
        if let delegate = delegate as? FeedTableViewDelegate {
            delegate.cellsAreSelectable = true
        }

        switch didSucceed {
        case true:  // TODO: add routing
            present(
                UIAlertController(
                    title: "Download Succeded.",
                    message: nil,
                    preferredStyle: .alert
                ),
                animated: true
            )

        case false:
            present(
                UIAlertController(
                    title: "Download Failed.",
                    message: nil,
                    preferredStyle: .alert
                ),
                animated: true
            )
        }
    }

}
