//
//  TabBarControllerDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A protocol representing a `UITabBarController` class which conforms to Destinations.
@MainActor public protocol TabBarControllerDestinationInterfacing<TabType>: TabBarDestinationInterfacing, ControllerDestinationInterfacing, UITabBarController where Destination: TabBarControllerDestinationable<DestinationType, ContentType, TabType> {

    /// Returns the currently presented controller in the specified tab.
    /// - Parameter tab: The tab type.
    /// - Returns: A `UIViewController`, if one is found.
    func currentController(for tab: TabType) -> (any ControllerDestinationInterfacing)?
    
    /// This method gives a chance to customize `UITabItem`s during tabs setup, and should be implemented in concrete `UITabBarController` classes conforming to this protocol.
    /// - Parameters:
    ///   - tab: The tab to customize.
    ///   - navigationController: The navigation controller whose `tabItem` property should be customized.
    func customizeTabItem(for tab: TabType, navigationController: UINavigationController)
    
    /// Returns the `tabIndex` for the requested tab type.
    /// - Parameter tab: The tab type.
    /// - Returns: The `tabIndex` of the tab, if the requested tab type was found.
    func tabIndex(for tab: TabType) -> Int?
    
    /// Returns a tab type associated with the specified Destination.
    /// - Parameter destinationID: The Destination identifier associated with the requested tab.
    /// - Returns: The requested tab type, if one was found.
    func tab(destinationID: UUID) -> TabType?
    
    /// Switches the active tab
    ///
    /// Note: Requesting a tab type that isn't in the active tabs list will result in a `DestinationsError.tabNotFound` error being thrown.
    /// - Parameter type: The type of tab to make to.
    func gotoTab(_ type: TabType) throws
}

public extension TabBarControllerDestinationInterfacing {
    func tabIndex(for tab: TabType) -> Int? {
        return destination().tabIndex(for: tab)
    }
    
    func tab(destinationID: UUID) -> TabType? {
        return destination().tab(destinationID: destinationID)
    }
    
    func gotoTab(_ type: TabType) throws {
        try destination().updateSelectedTab(type: type)
    }
    
    
    func currentController(for tab: TabType) -> (any ControllerDestinationInterfacing)? {
        if let navController = destination().navControllersForTabs[tab] {
            return navController.visibleViewController as? any ControllerDestinationInterfacing
        }
        return nil
    }

}
