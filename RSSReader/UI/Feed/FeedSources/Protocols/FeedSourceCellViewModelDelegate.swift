//
//  FeedSourceCellViewModelDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.10.23.
//

import Foundation

protocol FeedSourceCellViewModelDelegate: AnyObject {

    func didSelect(cellWithUrl url: URL)

}
