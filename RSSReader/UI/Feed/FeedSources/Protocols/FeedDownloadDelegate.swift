//
//  FeedDownloadDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 27.10.23.
//

import Foundation
import FeedKit

enum DownloadError: Error {
    case atomFeedDownloaded
    case jsonFeedDownloaded
    case feedNotDownloaded
}

typealias DownloadResult = Result<RSSFeed, DownloadError>

protocol FeedDownloadDelegate: AnyObject {

    func downloadStarted()

    func downloadCompleted(_ result: DownloadResult)

}
