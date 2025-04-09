//
//  GroupDestinationInternalStateable.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents classes which holds internal state specific to the ``GroupedDestinationable`` protocol.
public protocol GroupDestinationInternalStateable<DestinationType, ContentType, TabType> {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable

    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>
 
    /// An array of the child Destinations this object manages.
    var childDestinations: [any Destinationable<DestinationType, ContentType, TabType>] { get set }
    
    /// The child Destination which currently has focus within this Destination's children.
    var currentChildDestination: (any Destinationable<DestinationType, ContentType, TabType>)? { get set }
    
    /// A closure run when a child Destination is removed from this Group.
    var childWasRemovedClosure: GroupChildRemovedClosure? { get set }
    
    /// A closure run when the current child Destination has changed.
    var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure? { get set }
    
    /// Determines whether this Destination supports the `shouldSetDestinationAsCurrent` parameter of the `addChild` method. If this Destination should ignore requests to not make added children the current Destination, this property should be set to `false`.
    var supportsIgnoringCurrentDestinationStatus: Bool { get set }
}
