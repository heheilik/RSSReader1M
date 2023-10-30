//
//  FeedDownloadDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 27.10.23.
//

import Foundation

enum DownloadError: Error {
    case atomFeedDownloaded
    case jsonFeedDownloaded
    case feedNotDownloaded
}

protocol FeedDownloadDelegate: AnyObject {

    func downloadStarted()

    func downloadCompleted(withError error: DownloadError?)

}
