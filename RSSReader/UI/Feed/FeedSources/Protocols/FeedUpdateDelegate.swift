//
//  FeedUpdateDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 27.10.23.
//

import Foundation
import FeedKit

protocol FeedUpdateDelegate: AnyObject {
    func updateStarted()
    func updateCompleted(withError error: FeedUpdateManager.UpdateError?)
}
