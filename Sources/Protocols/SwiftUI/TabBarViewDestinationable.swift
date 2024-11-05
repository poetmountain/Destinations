//
//  TabBarViewDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A closure to be run when a Destination is presented in a tab.
public typealias TabBarViewDestinationPresentationClosure<PresentationConfiguration: DestinationPresentationConfiguring> = (_ destination: any ViewDestinationable<PresentationConfiguration>, _ tabViewID: UUID) -> Void

/// A closure to be run when the ``selectedTab`` property changed.
public typealias TabBarViewSelectedTabUpdatedClosure<TabType: TabTypeable> = (_ selectedTab: TabModel<TabType>) -> Void

/// This protocol represents a Destination whose interface view handles a `TabBar`.
@MainActor public protocol TabBarViewDestinationable<PresentationConfiguration, TabType>: ViewDestinationable, GroupedDestinationable where ViewType: TabBarViewDestinationInterfacing<TabType> {
    
    /// A dictionary of top-level Destination identifiers whose keys are their associated tab types.
    var destinationIDsForTabs: [TabType: UUID] { get set }

    /// A representation of the tabs that are currently active.
    var activeTabs: [TabModel<TabType>] { get set }
    
    /// The currently selected tab type. This property should be watched by the associated `TabView`'s selection state.
    var selectedTab: TabModel<TabType> { get set }
    
    /// A closure to be run when a Destination is presented in a tab.
    var destinationPresentationClosure: TabBarViewDestinationPresentationClosure<PresentationConfiguration>? { get set }
    
    /// A closure to be run when the ``selectedTab`` property changed.
    var selectedTabUpdatedClosure: TabBarViewSelectedTabUpdatedClosure<TabType>? { get set }
    
    /// Returns a tab type based on its associated Destination identifier.
    /// - Parameter destinationID: The Destination identifier.
    /// - Returns: A tab type, if one was found.
    func tab(destinationID: UUID) -> TabType?
    
    /// Returns a tab model for its associated type.
    /// - Parameter type: The type of tab.
    /// - Returns: A tab model, if one was found in the ``activeTabs`` array.
    func tab(for type: TabType) -> TabModel<TabType>?
    
    /// Returns the index of the specified tab in the ``activeTabs`` array.
    /// - Parameter type: The tab type.
    /// - Returns: An array index, if the tab was found in the array.
    func tabIndex(for type: TabType) -> Int?
    
    /// Assigns the closure to be run when the selected tab changes.
    /// - Parameter closure: The closure to run.
    func assignSelectedTabUpdatedClosure(closure: @escaping TabBarViewSelectedTabUpdatedClosure<TabType>)

    /// Update the currently selected tab.
    /// - Parameter tab: The tab type to select.
    func updateSelectedTab(type: TabType) throws
    
    /// Returns the current Destination for the specified tab.
    /// - Parameter tab: The tab type.
    /// - Returns: A `View`-based Destination, if one was found.
    func currentDestination(for tab: TabType) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    /// Returns the root Destination for the tab. This is not necessarily the Destination representing the currently visible `View` in a tab, but is instead the `View` which is presented in a `TabView`.
    ///
    /// This method should be used when building the tabs for a `TabView`.
    /// - Parameter tab: A tab type.
    /// - Returns: A Destination, if one was found.
    func rootDestination(for tab: TabType) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    /// Presents a Destination in a tab.
    ///
    /// - Note: This method will throw an error if the requested tab is not found.
    /// - Parameters:
    ///   - destination: A SwiftUI-based Destination to be presented.
    ///   - tab: The tab type to present this Destination in.
    ///   - shouldUpdateSelectedTab: Determines whether the selected tab should be updated.
    ///   - presentationOptions: A model which provides options for presenting this Destination within the tab when this tab includes a `NavigationStack`, including determining whether the presentation should be animated.
    func presentDestination(destination: any ViewDestinationable<PresentationConfiguration>, in tab: TabType, shouldUpdateSelectedTab: Bool, presentationOptions: NavigationStackPresentationOptions?) throws
    
    /// Assigns a presentation closure to be run when a Destination is presented in a tab.
    /// - Parameter closure: The closure to run.
    func assignPresentationClosure(closure: @escaping TabBarViewDestinationPresentationClosure<PresentationConfiguration>)
    
    /// Returns the identifier of the top-level Destination associated with this tab.
    /// - Parameter tab: The type of tab.
    /// - Returns: An identifier for the Destination, if one was found.
    func destinationIdentifier(for tab: TabType) -> UUID?
    
    /// Updates multiple Destinations in the specified tabs.
    /// - Parameters:
    ///   - destinationIDs: An array of Destination identifiers
    ///   - tabs: The tabs whose `View` stacks should be replaced.
    func updateTabViews(destinationIDs: [UUID], for tabs: [TabModel<TabType>])
}

public extension TabBarViewDestinationable {
    
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
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
    
    func destinationIdentifier(for tab: TabType) -> UUID? {
        return destinationIDsForTabs[tab]
    }
    
    func updateSelectedTab(type: TabType) throws {
        
        if var tab = tab(for: type) {
            selectedTab = tab
            
        } else {
            let template = DestinationsOptions.errorMessage(for: .tabNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            
            throw DestinationsError.tabNotFound(message: message)
        }
        
    }
    
    
    func rootDestination(for tab: TabType) -> (any ViewDestinationable<PresentationConfiguration>)? {
        guard let tabID = destinationIDsForTabs[tab] else { return nil }
        
        return childForIdentifier(destinationIdentifier: tabID) as? any ViewDestinationable<PresentationConfiguration>
    }
    
    
    func currentDestination(for tab: TabType) -> (any ViewDestinationable<PresentationConfiguration>)? {
        guard let tabID = destinationIDsForTabs[tab], let childDestination = childForIdentifier(destinationIdentifier: tabID) as? any ViewDestinationable<PresentationConfiguration> else { return nil }

        // If the top-level Destination is a NavigationStack, we need to return Destination of the current path element in its navigationPath. Otherwise, return the top-level Destination itself
        if let navDestination = childDestination as? any NavigatingViewDestinationable<PresentationConfiguration>, let navigator = navDestination.navigator(), let lastID = navigator.currentPathElement(), let lastDestination = navDestination.childForIdentifier(destinationIdentifier: lastID) as? any ViewDestinationable<PresentationConfiguration> {

            return lastDestination

        } else {
            return childDestination
        }
        return nil
    }
    
    func assignPresentationClosure(closure: @escaping TabBarViewDestinationPresentationClosure<PresentationConfiguration>) {
        destinationPresentationClosure = closure
    }
    
    func assignSelectedTabUpdatedClosure(closure: @escaping TabBarViewSelectedTabUpdatedClosure<TabType>) {
        selectedTabUpdatedClosure = closure
    }
    
    func presentDestination(destination: any ViewDestinationable<PresentationConfiguration>, in tab: TabType, shouldUpdateSelectedTab: Bool = true, presentationOptions: NavigationStackPresentationOptions? = nil) throws {
        DestinationsOptions.logger.log("Presenting tab view \(destination.type) in tab \(tab).")
       let currentTabDestination = rootDestination(for: tab)
        
        if shouldUpdateSelectedTab {
            currentChildDestination = destination
            try updateSelectedTab(type: tab)
        }
        
        // If the current Destination is a NavigationStack, add the presented Destination to it
        // Otherwise replace the current View with the new one
        if let navDestination = currentTabDestination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            addChild(childDestination: destination)
            let shouldAnimate = presentationOptions?.shouldAnimate ?? true
            navDestination.addChild(childDestination: destination, shouldAnimate: shouldAnimate)
            
        } else if let currentTabDestination {
            replaceChild(currentID: currentTabDestination.id, with: destination)
        } else {
            addChild(childDestination: destination)
        }
        
        if let navDestination = destination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            registerNavigationClosures(for: navDestination)
        }
        

    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>) {
        guard let currentIndex = childDestinations.firstIndex(where: { $0.id == currentID }), let currentDestination = childDestinations[safe: currentIndex] as? any ViewDestinationable, let currentTab = tab(destinationID: currentID) else {
            let template = DestinationsOptions.errorMessage(for: .childDestinationNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
        
        guard childDestinations.contains(where: { $0.id == newDestination.id}) == false else {
            DestinationsOptions.logger.log("Destination of type \(newDestination.type) was already in childDestinations, could not replace child \(currentID).", category: .error)
            return
        }

        DestinationsOptions.logger.log("Replacing tab destination with \(newDestination.type)")
        
        let shouldReplaceCurrentDestination = (currentChildDestination?.id == currentID)
        
        childDestinations.insert(newDestination, at: currentIndex)
        newDestination.parentDestinationID = id
        destinationIDsForTabs[currentTab] = newDestination.id
        
        removeChild(identifier: currentID)
        
        if shouldReplaceCurrentDestination {
            currentChildDestination = newDestination
        }
        
        if let navDestination = newDestination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            registerNavigationClosures(for: navDestination)
        }
        
        if let tab = view?.tab(destinationID: currentID), let newDestination = newDestination as? any ViewDestinationable {
            updateTabView(destinationID: newDestination.id, for: tab)
        }
        
    }
    
    func updateChildren() {
        let children = childDestinations.compactMap { $0.id }
        updateTabViews(destinationIDs: children, for: activeTabs)
        
    }
    
    func updateTabViews(destinationIDs: [UUID], for tabs: [TabModel<TabType>]) {
        
        destinationIDsForTabs.removeAll()
        for x in 0..<tabs.count {
            let type = tabs[x].type
            let destinationID = destinationIDs[x]
            destinationIDsForTabs[type] = destinationID
        }

        activeTabs = tabs

    }
    
    
    /// Updates the identifier of the top-level Destination shown for the specified tab. This is used internally by Destinations.
    /// - Parameters:
    ///   - destinationID: The identifier of the new Destination.
    ///   - type: The type of tab to update.
    internal func updateTabView(destinationID: UUID, for type: TabType) {

        self.destinationIDsForTabs[type] = destinationID
        let tabs = activeTabs
        activeTabs.removeAll()
        activeTabs = tabs
    }
    
    /// Registers this object for feedback with an associated NavigatingViewDestinationable class. This is used internally by Destinations to make sure that this object updates properly when there are changes in the NavigationStack.
    /// - Parameter destination: A Destination with an associated NavigationStack.
    internal func registerNavigationClosures(for destination: any NavigatingViewDestinationable<PresentationConfiguration>) {
        DestinationsOptions.logger.log("Registering navigation closures for \(destination.description)", level: .verbose)

        destination.assignChildRemovedClosure { [weak self] destinationID in
            DestinationsOptions.logger.log("Child was removed closure", level: .verbose)

            self?.removeChild(identifier: destinationID)
        }

        destination.assignCurrentDestinationChangedClosure { [weak self, weak destination] destinationID in
            DestinationsOptions.logger.log("Current destination changed closure", level: .verbose)

            if let destinationID {
                self?.updateCurrentDestination(destinationID: destinationID)
            } else {
                self?.currentChildDestination = destination
            }
        }
        
    }
}
