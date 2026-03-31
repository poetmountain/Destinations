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
    
    /// Returns the root Destination for the tab. This is not necessarily the Destination representing the currently visible `UIViewController` in a tab, but is instead the `UIViewController` which is at the root level of the column, such as a `UINavigationController`.
    ///
    /// This method should be used when building the tabs for a `UITabViewController`.
    /// - Parameter tab: A tab type.
    /// - Returns: A Destination, if one was found.
    func rootDestination(for tab: TabType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
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

    /// Updates multiple Destinations in the specified tabs.
    /// - Parameters:
    ///   - destinations: An array of Destinations
    ///   - tabs: The tabs whose `UIViewController` stacks should be replaced.
    func updateTabControllers(destinations: [any ControllerDestinationable<DestinationType, ContentType, TabType>], for tabs: [TabModel<TabType>])
    
    /// Finds a Destination of the specified type within the children of this `UITabBarController`.
    /// - Parameters:
    ///   - typeToFind: The type of Destination to find.
    ///   - currentLevel: The current level of the view hierarchy to search at.
    /// - Returns: A Destination of the specified type, if one was found.
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
}

public extension TabBarControllerDestinationable {
    
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func rootDestination(for tab: TabType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        guard let tabID = destinationIDsForTabs[tab] else { return nil }
        
        return childForIdentifier(destinationIdentifier: tabID) as? any ControllerDestinationable<DestinationType, ContentType, TabType>
    }
    
    func currentDestination(for tab: TabType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        guard let tabID = destinationIDsForTabs[tab], let childDestination = childForIdentifier(destinationIdentifier: tabID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> else { return nil }

        // If the top-level Destination is a UINavigationController, we need to return Destination of the current path element in its navigationPath. Otherwise, return the top-level Destination itself
        if let navDestination = childDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>, let lastID = navDestination.childDestinations().last?.id, let lastDestination = navDestination.childForIdentifier(destinationIdentifier: lastID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {

            return lastDestination

        } else {
            return childDestination
        }
        return nil
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
        guard let destinationController = controllerToMatch as? any ControllerDestinationInterfacing else { return nil }
        
        for (tab, uuid) in destinationIDsForTabs {
            if destinationController.destination().id == uuid {
                return tab
            }

        }
        
        return nil
    }

    public func presentDestination(destination: any ControllerDestinationable<DestinationType, ContentType, TabType>, in tab: TabType, shouldUpdateSelectedTab: Bool = true, presentationOptions: NavigationStackPresentationOptions? = nil, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) throws {
        DestinationsSupport.logger.log("Presenting tab controller \(destination.type) in tab \(tab).")

        let currentTabDestination = rootDestination(for: tab)
        
        DestinationsSupport.logger.log("current tab dest \(currentTabDestination?.type)")
        
        if shouldUpdateSelectedTab {
            groupInternalState.currentChildDestination = destination
            try updateSelectedTab(type: tab)
        }
        
        // If the current Destination is a NavigatingControllerDestinationable, add the presented Destination to it
        // Otherwise replace the current Destination with the new one
        if let navDestination = currentTabDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            addChild(childDestination: destination)
            destination.setParentID(id: navDestination.id)
            let shouldAnimate = presentationOptions?.shouldAnimate ?? true
            navDestination.addChild(childDestination: destination, shouldAnimate: shouldAnimate)
            
        } else if let currentTabDestination {
            replaceChild(currentID: currentTabDestination.id, with: destination, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        } else {
            addChild(childDestination: destination)

        }

        if let navDestination = destination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            registerNavigationClosures(for: navDestination)
        }
    }
    
    func addChild(childDestination: any Destinationable<DestinationType, ContentType, TabType>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
        
        guard let childControllerDestination = childDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let childController = childControllerDestination.currentController() else { return }
        
        groupInternalState.childDestinations.append(childDestination)
        childDestination.setParentID(id: id)
        
    }
    
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {

        guard let newDestination = newDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType> else { return }
        
        guard let currentIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == currentID }), let destinationToReplace = groupInternalState.childDestinations[safe: currentIndex] as? any ControllerDestinationable, let tabToReplace = tab(destinationID: currentID) else {
            let template = DestinationsSupport.errorMessage(for: .childDestinationNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
        
        guard groupInternalState.childDestinations.contains(where: { $0.id == newDestination.id}) == false else {
            DestinationsSupport.logger.log("Destination of type \(newDestination.type) was already in childDestinations, could not replace child \(currentID).", category: .error)
            return
        }

        DestinationsSupport.logger.log("Replacing tab \(tabToReplace) destination with \(newDestination.type)")
        
        DestinationsSupport.logger.log("Current tab VC \(self.currentDestination(for: tabToReplace))")
        
        let shouldReplaceCurrentDestination = (currentChildDestination()?.id == currentID)
        
        groupInternalState.childDestinations.insert(newDestination, at: currentIndex)
        newDestination.setParentID(id: id)
        
        removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        
        if shouldReplaceCurrentDestination {
            groupInternalState.currentChildDestination = newDestination
            
        }
        
        if let navDestination = newDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            registerNavigationClosures(for: navDestination)
        }
        
        updateTabController(destinationID: newDestination.id, for: tabToReplace)

    }
    
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        if let parentID = currentLevel.parentDestinationID(), let parentDestination = childForIdentifier(destinationIdentifier: parentID) as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            return parentDestination.findDestination(typeToFind: typeToFind, currentLevel: currentLevel)
        }
        
        if let current = currentDestination(for: selectedTab.type) {
            if current.type == typeToFind {
                return current
                
            } else if let navDestination = current as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
                
                return navDestination.findDestination(typeToFind: typeToFind, currentLevel: current)
            }
        }
        
        return nil
    }
    
    
    func assignSelectedTabUpdatedClosure(closure: @escaping TabBarControllerSelectedTabUpdatedClosure<TabType>) {
        selectedTabUpdatedClosure = closure
    }
    
    
    func updateChildren() {
        if let childDestinations = groupInternalState.childDestinations as? [any ControllerDestinationable<DestinationType, ContentType, TabType>] {
            updateTabControllers(destinations: childDestinations, for: activeTabs)
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
        
        var childDestinations = [any ControllerDestinationable<DestinationType, ContentType, TabType>]()
        for tab in tabs {
            if let destination = self.currentDestination(for: tab.type) {
                childDestinations.append(destination)
            }
        }
        let childControllers = childDestinations.compactMap { $0.currentController() }
        if let tabController = currentController() as? UITabBarController {
            tabController.setViewControllers(childControllers, animated: false)
        }
        
        
    }
    
    /// Registers this object for feedback with an associated NavigatingControllerDestinationable class. This is used internally by Destinations to make sure that this object updates properly when there are changes in the UINavigationController.
    /// - Parameter destination: A Destination with an associated NavigationStack.
    internal func registerNavigationClosures(for destination: any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>) {
        DestinationsSupport.logger.log("Registering navigation closures for \(destination.description)", level: .verbose)

        destination.assignChildRemovedClosure { [weak self] destinationID in
            DestinationsSupport.logger.log("Child was removed closure", level: .verbose)

            self?.removeChild(identifier: destinationID, removeDestinationFromFlowClosure: nil)
        }

        destination.assignCurrentDestinationChangedClosure { [weak self, weak destination] destinationID in
            DestinationsSupport.logger.log("Current destination changed closure", level: .verbose)

            if let destinationID {
                self?.updateCurrentDestination(destinationID: destinationID)
            } else {
                self?.groupInternalState.currentChildDestination = destination
            }
        }
        
    }
}
