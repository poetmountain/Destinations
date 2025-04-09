//
//  GroupDestinationInternalState.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This class holds internal state specific to the ``GroupedDestinationable`` protocol.
public final class GroupDestinationInternalState<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>: GroupDestinationInternalStateable {
       
    public var childDestinations: [any Destinationable<DestinationType, ContentType, TabType>] = []
    public var currentChildDestination: (any Destinationable<DestinationType, ContentType, TabType>)?
    
    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?
    
    public var supportsIgnoringCurrentDestinationStatus: Bool = false

    public init() {}

}
