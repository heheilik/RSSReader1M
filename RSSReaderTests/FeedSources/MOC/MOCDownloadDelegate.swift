//
//  MOCDownloadDelegate.swift
//  RSSReaderTests
//
//  Created by Heorhi Heilik on 22.11.23.
//

import Foundation

class MOCDownloadDelegate: FeedDownloadDelegate {

    var didDownloadStart = false

    func downloadStarted() {
        didDownloadStart = true
    }

    func downloadCompleted(_ result: DownloadResult) {
    }

}
