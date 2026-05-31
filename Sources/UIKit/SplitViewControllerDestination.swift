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
public final class SplitViewControllerDestination<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: SplitViewControllerDestinationable {
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    public typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>
    
    public typealias InteractorType = InteractorType
    public typealias ControllerType = SplitViewController<EventType, DestinationType, ContentType, TabType, InteractorType>
    public typealias PresentationType = DestinationPresentation<DestinationType, ContentType, TabType>.PresentationType

    public let id = UUID()
    
    public let type: DestinationType
        
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()
    
    public var destinationIDsForColumns: [UISplitViewController.Column: UUID] = [:]

    public var stateModel: (any StateModeling<SplitViewControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>>)?

    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - destinationsForColumns: A dictionary of `UIViewController`-based Destination objects, whose associated keys are the `UISplitViewController.Column` column type should be displayed in.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init(type: DestinationType, destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<DestinationType, ContentType, TabType>], destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil, state: (any StateModeling<SplitViewControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>>)? = nil) {
        self.type = type
        self.stateModel = state
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
        self.internalState.parentDestinationID = parentDestinationID
        
        for (column, destination) in destinationsForColumns {
            destinationIDsForColumns[column] = destination.id
            presentDestination(destination: destination, in: column)
        }
        
    }
    
}
