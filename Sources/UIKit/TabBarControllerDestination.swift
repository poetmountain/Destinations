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
public final class TabBarControllerDestination<PresentationConfiguration: DestinationPresentationConfiguring, TabControllerType: TabBarControllerDestinationInterfacing>: TabBarControllerDestinationable where PresentationConfiguration.DestinationType == TabControllerType.DestinationType, PresentationConfiguration.TabType == TabControllerType.TabType {
    
    public typealias ControllerType = TabControllerType
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    public typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, PresentationConfiguration>
    
    public typealias DestinationType = TabControllerType.DestinationType
    public typealias TabType = TabControllerType.TabType
    public typealias ContentType = PresentationConfiguration.ContentType
    public typealias InteractorType = TabControllerType.InteractorType
    public typealias PresentationConfiguration = PresentationConfiguration
    public typealias UserInteractionType = TabControllerType.UserInteractionType
        
    public let id = UUID()
    
    public let type: DestinationType
        
    public var controller: ControllerType?
    
    public var parentDestinationID: UUID?
                
    public var destinationIDsForTabs: [TabType : UUID] = [:]
    
    public var activeTabs: [TabModel<TabType>] = []
    
    public var selectedTab: TabModel<TabType>
    
    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<TabBarControllerDestination>] = [:]

    
    public var navControllersForTabs: [TabType : UINavigationController] = [:]

    public var destinationConfigurations: DestinationConfigurations?

    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?
    public var selectedTabUpdatedClosure: TabBarControllerSelectedTabUpdatedClosure<TabType>?

    public var isSystemNavigating: Bool = false
    
    
    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - tabDestinations: An array of Destinations for each tab, in order of appearance.
    ///   - tabTypes: An array of tab types, in order of appearance.
    ///   - selectedTab: The type of tab that should be initially selected.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init?(type: DestinationType, tabDestinations: [any ControllerDestinationable<PresentationConfiguration>], tabTypes: [TabType], selectedTab: TabType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = type
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
        self.parentDestinationID = parentDestinationID
        self.currentChildDestination = tabDestinations.first
        
        var tabModels: [TabModel<TabType>] = []
        var selectedModel: TabModel<TabType>?
        
        for (index, type) in tabTypes.enumerated() {
            let model = TabModel(type: type)
            tabModels.append(model)
            if type == selectedTab {
                selectedModel = model
                self.currentChildDestination = tabDestinations[index]
            }
        }
        self.activeTabs = tabModels
        
        if let selectedModel {
            self.selectedTab = selectedModel
        } else {
            DestinationsOptions.logger.log("The specified selectedTab type was not found in the supplied tabs array. Initialization of TabViewDestination failed.", category: .error)
            return nil
        }
        
        updateTabControllers(controllers: tabDestinations.map { $0.id }, for: tabModels)
        
        for (index, tab) in tabTypes.enumerated() {
            if let destination = tabDestinations[safe: index] {
                do {
                    try presentDestination(destination: destination, in: tab, shouldUpdateSelectedTab: false)
                } catch {
                    DestinationsOptions.logger.log("Error presenting tab Destination \(error)", category: .error)
                }
            }
        }
    }
    


}
