//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()
        window?.rootViewController = FeedViewController(
            sectionViewModels: [FeedsSourcesListSection()]
        )
        window?.makeKeyAndVisible()

        return true
    }

}

