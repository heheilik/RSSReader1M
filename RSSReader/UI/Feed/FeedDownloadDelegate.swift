//
//  FeedDownloadDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 27.10.23.
//

import Foundation

protocol FeedDownloadDelegate: AnyObject {

    func downloadStarted()
    func downloadCompleted(didSucceed: Bool)

}
