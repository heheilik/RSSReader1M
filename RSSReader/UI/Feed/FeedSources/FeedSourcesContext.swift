//
//  FeedSourcesContext.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.10.23.
//

import ALNavigation
import Foundation

struct FeedSourcesContext: PageContext {

    let data = [
        FeedSource(name: "Рамблер. В мире", url: URL(string: "https://news.rambler.ru/rss/world")!),
        FeedSource(name: "Swift", url: URL(string: "https://www.swift.org/atom.xml")!)
    ]

}
