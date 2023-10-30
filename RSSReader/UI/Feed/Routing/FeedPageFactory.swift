//
//  FeedPageFactory.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 30.10.23.
//

import ALNavigation
import Foundation
import UIKit

struct FeedPageFactory: PageFactoryProtocol {

    enum NavigationPath: String, CaseIterable {
        case feedEntries = "/feedEntries"
    }

    // MARK: Internal methods

    func controller(for path: String, with context: PageContext?) throws -> UIViewController {
        guard let typedPath = NavigationPath(rawValue: path) else {
            throw PageFactoryErrorType.NavigationPathNotHandled
        }
        switch typedPath {
        case .feedEntries:
            fatalError("Not implemented.", file: #file, line: #line)
        }
    }

}
