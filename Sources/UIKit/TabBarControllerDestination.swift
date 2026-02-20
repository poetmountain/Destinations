//
//  TabBarControllerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A Destination which represents a UIKit `UITabViewController`.
///
/// This is a generic Destination that can be used to represent most `UITabViewController`s in a UIKit-based app.
@Observable
public final class TabBarControllerDestination<ControllerType: TabBarControllerDestinationInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: TabBarControllerDestinationable {
            
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    public typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>
 
    public typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>

    public let id = UUID()
    
    public let type: DestinationType
        
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()
              
                    
    public var destinationIDsForTabs: [TabType : UUID] = [:]
    
    public var activeTabs: [TabModel<TabType>] = []
    
    public var selectedTab: TabModel<TabType> {
        didSet {
            print("update selected tab")
            selectedTabUpdatedClosure?(selectedTab)
        }
    }
    
    
    public var navControllersForTabs: [TabType : UINavigationController] = [:]

    public var selectedTabUpdatedClosure: TabBarControllerSelectedTabUpdatedClosure<TabType>?

    
    
    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - tabDestinations: An array of Destinations for each tab, in order of appearance.
    ///   - tabTypes: An array of tab types, in order of appearance.
    ///   - selectedTab: The type of tab that should be initially selected.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init?(type: DestinationType, tabDestinations: [any ControllerDestinationable<DestinationType, ContentType, TabType>], tabTypes: [TabType], selectedTab: TabType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = type
 
        var tabModels: [TabModel<TabType>] = []
        var selectedModel: TabModel<TabType>?
        var selectedIndex: Int?
        
        for tabDestination in tabDestinations {
            tabDestination.setParentID(id: id)
        }
        
        for (index, type) in tabTypes.enumerated() {
            let model = TabModel(type: type)
            tabModels.append(model)
            if type == selectedTab {
                selectedModel = model
                selectedIndex = index
            }
        }
        self.activeTabs = tabModels
        
        if let selectedModel {
            self.selectedTab = selectedModel
        } else if let first = tabModels.first {
            self.selectedTab = first
        } else {
            DestinationsSupport.logger.log("The specified selectedTab type was not found in the supplied tabs array. Initialization of TabViewDestination failed.", category: .error)
            return nil
        }
        
        if let selectedIndex {
            groupInternalState.currentChildDestination = tabDestinations[selectedIndex]
        }
        
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
        self.internalState.parentDestinationID = parentDestinationID
        self.groupInternalState.currentChildDestination = tabDestinations.first

        updateTabControllers(destinations: tabDestinations, for: tabModels)
        
        for (index, tab) in tabTypes.enumerated() {
            if let destination = tabDestinations[safe: index] {
                do {
                    try presentDestination(destination: destination, in: tab, shouldUpdateSelectedTab: false)
                } catch {
                    DestinationsSupport.logger.log("Error presenting tab Destination \(error)", category: .error)
                }
            }
        }
        
    }
    
    public func updateTabControllers(destinations: [any ControllerDestinationable<DestinationType, ContentType, TabType>], for tabs: [TabModel<TabType>]) {
        
        let destinationIDs = destinations.compactMap { $0.id }
        
        destinationIDsForTabs.removeAll()
        for x in 0..<tabs.count {
            let type = tabs[x].type
            let destinationID = destinationIDs[x]
            destinationIDsForTabs[type] = destinationID
        }

        activeTabs = tabs
        
        let childControllers = destinations.compactMap { $0.currentController() }
        
        currentController()?.setViewControllers(childControllers, animated: false)

        for (index, destination) in destinations.enumerated() {
            let tab = tabs[index]
            if let tabType = tab.type as? ControllerType.TabType, let controller = destination.currentController() {
                currentController()?.customizeTabItem(for: tabType, controller: controller)
            }
        }
    }
    
    public func prepareForPresentation() {
    }
    
    public func updateSelectedTab(type: TabType) throws {
        
        if var tab = tab(for: type) {
            selectedTab = tab
            
            if let tabIndex = self.tabIndex(for: type) {
                controller?.selectedIndex = tabIndex
            }
        } else {
            let template = DestinationsSupport.errorMessage(for: .tabNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            
            throw DestinationsError.tabNotFound(message: message)
        }
        
    }
    
    /// Sets up the `UINavigationController` containers for each tab. These navigation controllers are transparent to the Destinations ecosystem, but facilitate pushing a Destination onto a tab. This is used internally by Destinations.
    internal func setupTabsNavigationControllers() {
        
        navControllersForTabs.removeAll()
        for tab in activeTabs {
            let navController = UINavigationController()
            navControllersForTabs[tab.type] = navController
        }
        
        for (tab, navController) in navControllersForTabs {
            if let tab = tab as? ControllerType.TabType {
                controller?.customizeTabItem(for: tab, controller: navController)
            }
        }

        var tabs: [UINavigationController] = []
        for tab in activeTabs {
            if let navigationController = navControllersForTabs[tab.type] {
                tabs.append(navigationController)
            }
        }

        controller?.setViewControllers(tabs, animated: false)

    }
    
    
}
