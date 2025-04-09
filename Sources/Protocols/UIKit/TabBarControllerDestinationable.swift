//
//  TabBarControllerDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A closure to be run when the ``selectedTab`` property of a ``TabBarControllerDestinationable`` object has changed.
public typealias TabBarControllerSelectedTabUpdatedClosure<TabType: TabTypeable> = (_ selectedTab: TabModel<TabType>) -> Void

/// This protocol represents a Destination whose interface is a `UITabBarController`.
@MainActor public protocol TabBarControllerDestinationable<DestinationType, ContentType, TabType>: GroupedControllerDestinationable {
    
    /// A dictionary of UINavigationControllers whose keys are their associated tab types.
    var navControllersForTabs: [TabType: UINavigationController] { get set }
    
    /// A dictionary of Destination identifiers whose keys are their associated tab types.
    var destinationIDsForTabs: [TabType: UUID] { get set }

    /// A representation of the tab types that are currently active.
    var activeTabs: [TabModel<TabType>] { get set }
    
    /// The currently selected tab type.
    var selectedTab: TabModel<TabType> { get set }
    
    /// Update the currently selected tab.
    /// - Parameter tab: The tab type to select.
    func updateSelectedTab(type: TabType) throws
    
    /// Returns the current Destination for the specified tab.
    /// - Parameter tab: The tab type.
    /// - Returns: A `View`-based Destination, if one was found.
    func currentDestination(for tab: TabType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// A closure to be run when the ``selectedTab`` property changed.
    var selectedTabUpdatedClosure: TabBarControllerSelectedTabUpdatedClosure<TabType>? { get set }
    
    
    /// Presents a Destination in a tab.
    ///
    /// - Note: This method will throw an error if the requested tab is not found.
    /// - Parameters:
    ///   - destination: A UIKit-based Destination to be presented.
    ///   - tab: The tab type to present this Destination in.
    ///   - shouldUpdateSelectedTab: Determines whether the selected tab should be updated.
    ///   - presentationOptions: A model which provides options for presenting this Destination in the `UINavigationController` within the tab, including determining whether the presentation should be animated.
    func presentDestination(destination: any ControllerDestinationable<DestinationType, ContentType, TabType>, in tab: TabType, shouldUpdateSelectedTab: Bool, presentationOptions: NavigationStackPresentationOptions?, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?) throws
    
    /// Registers the specified `UINavigationControllerDelegate` with the `UINavigationController` root objects in each tab.
    /// - Parameter coordinator: The `UINavigationControllerDelegate` coordinator object to register.
    func registerNavigationControllerDelegates(with coordinator: any DestinationUIKitCoordinating)

    /// Returns a tab based on its associated Destination identifier.
    /// - Parameter destinationID: The Destination identifier.
    /// - Returns: A tab type, if one was found.
    func tab(destinationID: UUID) -> TabType?

    /// Returns a tab model for its associated type.
    /// - Parameter type: The type of tab.
    /// - Returns: A tab model, if one was found in the ``activeTabs`` array.
    func tab(for type: TabType) -> TabModel<TabType>?
    
    /// Returns the tab which contains the specified `UIViewController`.
    /// - Parameter controllerToMatch: A controller to find.
    /// - Returns: A tab type, if one was found.
    func tab(containing controllerToMatch: UIViewController) -> TabType?
    
    /// Returns the index of the specified tab in the ``activeTabs`` array.
    /// - Parameter type: The tab type.
    /// - Returns: An array index, if the tab was found in the array.
    func tabIndex(for type: TabType) -> Int?
    
    /// Assigns the closure to be run when the selected tab changes.
    /// - Parameter closure: The closure to run.
    func assignSelectedTabUpdatedClosure(closure: @escaping TabBarControllerSelectedTabUpdatedClosure<TabType>)

}

public extension TabBarControllerDestinationable {
    
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func currentDestination(for tab: TabType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        if let navController = navControllersForTabs[tab], let currentController = navController.visibleViewController as? any ControllerDestinationInterfacing {
            return currentController.destination() as? any ControllerDestinationable<DestinationType, ContentType, TabType>
        }
        
        return nil
    }
    
    func registerNavigationControllerDelegates(with coordinator: any DestinationUIKitCoordinating) {
        guard let controller else { return }
        
        for navController in navControllersForTabs.values {
            navController.delegate = coordinator
        }
    }
    
    func tab(destinationID: UUID) -> TabType? {
        return destinationIDsForTabs.first(where: { $0.value == destinationID })?.key
    }
    
    func tab(for type: TabType) -> TabModel<TabType>? {
        return activeTabs.first(where: { $0.type == type })
    }
    
    func tabIndex(for type: TabType) -> Int? {
        return activeTabs.firstIndex(where: { $0.type == type })
    }
    
    func tab(containing controllerToMatch: UIViewController) -> TabType? {
        
        for (tab, navController) in navControllersForTabs {
            if navController == controllerToMatch {
                return tab
            }
            
            if navController.viewControllers.first(where: { $0 == controllerToMatch }) != nil {
                return tab
            }
        }
        
        return nil
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        guard let controller, let currentIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == currentID }), let currentDestination = groupInternalState.childDestinations[safe: currentIndex] as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let currentController = currentDestination.currentController() else { return }
  
        if groupInternalState.childDestinations.contains(where: { $0.id == newDestination.id}) == false {
            groupInternalState.childDestinations.insert(newDestination, at: currentIndex)
            newDestination.setParentID(id: id)
        }
        
        if groupInternalState.currentChildDestination?.id == currentID {
            groupInternalState.currentChildDestination = newDestination
        }
        
        removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        
        if let tab = self.tab(destinationID: currentID), let newDestination = newDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            updateTabController(destinationID: newDestination.id, for: tab)
            addContentToNavigationController(tab: tab)
        }
                
    }
    
    
    
    func assignSelectedTabUpdatedClosure(closure: @escaping TabBarControllerSelectedTabUpdatedClosure<TabType>) {
        selectedTabUpdatedClosure = closure
    }
    
    /// Adds the children Destination controllers to each tab's UINavigationController stack. This is used internally by Destinations.
    internal func addContentToNavigationController(tab: TabType) {

        if let controllerID = destinationIDsForTabs[tab], let tabDestination = groupInternalState.childDestinations.first(where: { $0.id == controllerID }) as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let controller = tabDestination.currentController(), let navigationController = navControllersForTabs[tab] {
            navigationController.setViewControllers([controller], animated: false)
        }
    }
    

    
    /// Updates the identifier of the top-level Destination shown for the specified tab. This is used internally by Destinations.
    /// - Parameters:
    ///   - destinationID: The Destination identifier.
    ///   - type: The tab type to update.
    internal func updateTabController(destinationID: UUID, for type: TabType) {
        
        self.destinationIDsForTabs[type] = destinationID
        let tabs = activeTabs
        activeTabs.removeAll()
        activeTabs = tabs
    }
    
    
}
