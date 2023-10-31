//
//  FeedSourcesSectionViewModelDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.10.23.
//

import Foundation

protocol FeedSourcesSectionViewModelDelegate: AnyObject {

    func didSelect(cellWithData feedSource: FeedSource)

}
