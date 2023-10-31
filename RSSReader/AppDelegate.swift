//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import ALNavigation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PageFactoryDependency {

    // MARK: Internal Properties

    var window: UIWindow?

    // MARK: Internal Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()
//        window?.rootViewController = FeedViewController(
//            sectionViewModels: [FeedSourcesSectionViewModel()]
//        )
        window?.rootViewController = UINavigationController(rootViewController: )
        window?.makeKeyAndVisible()

        registerFactory()

        return true
    }

    // MARK: Private methods

    private func registerFactory() {
        pageFactory.register(FeedPageFactory.self)
    }

}

