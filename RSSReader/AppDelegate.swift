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
        let window = UIWindow()
        window.rootViewController = FeedViewController()
        self.window = window
        window.makeKeyAndVisible()

        return true
    }

}

