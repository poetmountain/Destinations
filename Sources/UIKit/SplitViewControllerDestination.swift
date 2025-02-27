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
    
    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<PresentationType, PresentationConfiguration> = GroupDestinationInternalState()
                    
    public var destinationIDsForColumns: [UISplitViewController.Column: UUID] = [:]

    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - destinationsForColumns: A dictionary of `UIViewController`-based Destination objects, whose associated keys are the `UISplitViewController.Column` column type should be displayed in.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init(type: DestinationType, destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<PresentationConfiguration>], destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = type
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
        self.internalState.parentDestinationID = parentDestinationID
        
        for (column, destination) in destinationsForColumns {
            destinationIDsForColumns[column] = destination.id
            presentDestination(destination: destination, in: column)
        }
        
    }
    
    public func prepareForPresentation() {
    }
    
}
