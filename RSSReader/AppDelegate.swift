//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Private Properties

    private var window: UIWindow?

    // MARK: Internal Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()
        window?.rootViewController = FeedViewController(
            sectionViewModels: [FeedSourcesSectionViewModel()]
        )
        window?.makeKeyAndVisible()

        return true
    }

}

