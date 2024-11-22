//
//  SplitViewControllerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A Destination which represents a UIKit `UISplitViewController`.
///
/// This is a generic Destination that can be used to represent most `UISplitViewController`s in a UIKit-based app.
public final class SplitViewControllerDestination<PresentationConfiguration: DestinationPresentationConfiguring, SplitViewControllerType: SplitViewControllerDestinationInterfacing>: SplitViewControllerDestinationable where PresentationConfiguration.DestinationType == SplitViewControllerType.DestinationType {
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    public typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, PresentationConfiguration>
    
    public typealias DestinationType = SplitViewControllerType.DestinationType
    public typealias TabType = PresentationConfiguration.TabType
    public typealias ContentType = PresentationConfiguration.ContentType
    public typealias InteractorType = SplitViewControllerType.InteractorType
    public typealias PresentationConfiguration = PresentationConfiguration
    public typealias UserInteractionType = SplitViewControllerType.UserInteractionType
    public typealias ControllerType = SplitViewControllerType
    public typealias PresentationType = PresentationConfiguration.PresentationType

    public let id = UUID()
    
    public let type: DestinationType
        
    public var controller: ControllerType?
    
    public var parentDestinationID: UUID?
                
    public var destinationIDsForColumns: [UISplitViewController.Column: UUID] = [:]
    
    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<SplitViewControllerDestination>] = [:]
    
    public var destinationConfigurations: DestinationConfigurations?

    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?

    public var supportsIgnoringCurrentDestinationStatus: Bool = true

    public var isSystemNavigating: Bool = false
    
    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - destinationsForColumns: A dictionary of `UIViewController`-based Destination objects, whose associated keys are the `UISplitViewController.Column` column type should be displayed in.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init(type: DestinationType, destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<PresentationConfiguration>], destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = type
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
        self.parentDestinationID = parentDestinationID
        
        for (column, destination) in destinationsForColumns {
            destinationIDsForColumns[column] = destination.id
            presentDestination(destination: destination, in: column)
        }
        
    }
    
}