//
//  FeedEntriesViewController.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedEntriesViewController: FMTablePageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource?.sectionViewModels.forEach {
            ($0 as? FMAnimatable)?.startAnimation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem { [weak self] in
            self?.dataSource?.sectionViewModels.forEach {
                ($0 as? FMAnimatable)?.stopAnimation()
            }
        })
    }
}
