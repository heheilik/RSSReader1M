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
        registerFactory()

        window = UIWindow()
        window?.rootViewController = UINavigationController(
            rootViewController: newRootViewController()
        )
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: Private methods

    private func registerFactory() {
        pageFactory.register(FeedPageFactory.self)
    }

    private func newRootViewController() -> FeedSourcesViewController {
        guard let viewController = try? FeedPageFactory().controller(
            for: FeedPageFactory.NavigationPath.feedSources.rawValue,
            with: FeedSourcesContext.moc
        ) else {
            fatalError("Could not instantiate root view controller.")
        }
        guard let viewController = viewController as? FeedSourcesViewController else {
            fatalError("Wrong view controller instantiated.")
        }
        return viewController
    }

}

