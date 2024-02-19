//
//  Factory+EntryDateFormatter.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 12.02.24.
//

import Factory
import Foundation

extension Container {
    var entryDateFormatter: Factory<DateFormatter> {
        self {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }.singleton
    }
}
