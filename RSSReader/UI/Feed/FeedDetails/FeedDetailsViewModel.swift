//
//  FeedDetailsViewModel.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 1.11.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedDetailsViewModel: FMPageViewModel {

    let context: FeedDetailsContext

    init(context: FeedDetailsContext) {
        self.context = context
        super.init()
    }

}
