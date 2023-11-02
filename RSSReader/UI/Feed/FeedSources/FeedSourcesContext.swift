//
//  FeedSourcesContext.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 31.10.23.
//

import ALNavigation
import Foundation

struct FeedSourcesContext: PageContext {

    let data: [FeedSource]

}

extension FeedSourcesContext {

    static let moc = FeedSourcesContext(data: [
        FeedSource(name: "Рамблер. В мире", url: URL(string: "https://news.rambler.ru/rss/world")!),
        FeedSource(name: "Swift", url: URL(string: "https://www.swift.org/atom.xml")!),
        FeedSource(name: "ООН. Последние сообщения", url: URL(string: "https://news.un.org/feed/subscribe/ru/news/all/rss.xml")!),
        FeedSource(name: "CNET News", url: URL(string: "https://www.cnet.com/rss/news/")!),
        FeedSource(name: "WSJ World News", url: URL(string: "https://feeds.a.dj.com/rss/RSSWorldNews.xml")!),
        FeedSource(name: "Skynews", url: URL(string: "http://feeds.skynews.com/feeds/rss/home.xml")!),
    ])

}
