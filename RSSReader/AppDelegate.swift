//
//  AppDelegate.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 25.10.23.
//

import ALNavigation
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, PageFactoryDependency {

    // MARK: Internal Properties

    var window: UIWindow?

    // MARK: Internal Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerFactory()
        configureTableViewAppearance()

        window = UIWindow()
        window?.rootViewController = newNavigationController()
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: Private methods

    private func registerFactory() {
        pageFactory.register(FeedPageFactory.self)
    }

    private func newNavigationController() -> UINavigationController {
        UINavigationController(
            rootViewController: newRootViewController()
        )
    }

    private func newRootViewController() -> FeedSourcesViewController {
        guard let viewController = try? FeedPageFactory().controller(
            for: FeedPageFactory.NavigationPath.feedSources.rawValue,
            with: FeedSourcesContext.mock
        ) else {
            fatalError("Could not instantiate root view controller.")
        }
        guard let viewController = viewController as? FeedSourcesViewController else {
            fatalError("Wrong view controller instantiated.")
        }
        return viewController
    }

    private func configureTableViewAppearance() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
}

