//
//  FeedTableViewDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 27.10.23.
//

import FMArchitecture
import Foundation
import UIKit

class FeedTableViewDelegate: FMTableViewDelegate {

    // MARK: Internal Properties

    var cellsAreSelectable = true

    // MARK: Internal Methods

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return cellsAreSelectable ? indexPath : nil
    }

}
