//
//  Collection+Safe.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 21.02.24.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
