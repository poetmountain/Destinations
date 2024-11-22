//
//  TabBarViewDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A protocol defining a SwiftUI `View` which handles a `TabView` and conforms to Destinations.
@MainActor public protocol TabBarViewDestinationInterfacing<TabType>: View, TabBarDestinationInterfacing, ViewDestinationInterfacing where Destination: TabBarViewDestinationable<PresentationConfiguration, TabType>, DestinationState.Destination == Destination {
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring

    /// Replaces a `View` in the specified tab with a new one.
    /// - Parameters:
    ///   - view: The `View` to be replaced.
    ///   - tab: The tab type of the `View` to be replaced.
    ///   - newView: The new `View`.
    func replaceViews(in tab: TabType, with newDestinationID: UUID)
    
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

public extension TabBarViewDestinationInterfacing {
    func tabIndex(for tab: TabType) -> Int? {
        return destination().tabIndex(for: tab)
    }
    
    func tab(destinationID: UUID) -> TabType? {
        return destination().tab(destinationID: destinationID)
    }
    
    func gotoTab(_ type: TabType) throws {
        try destination().updateSelectedTab(type: type)
    }
    
    func replaceViews(in tab: TabType, with newDestinationID: UUID) {
        guard destination().activeTabs.map { $0.type }.contains(tab) else {
            DestinationsSupport.logger.log("Active tabs doesn't contain tab \(tab)", category: .error)
            return
        }
    
        destination().updateTabView(destinationID: newDestinationID, for: tab)
        
    }
    

}
