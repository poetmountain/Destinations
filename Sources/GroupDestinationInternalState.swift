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
public final class GroupDestinationInternalState<PresentationType: DestinationPresentationTypeable, PresentationConfiguration: DestinationPresentationConfiguring>: GroupDestinationInternalStateable {
    
    public typealias DestinationType = PresentationConfiguration.DestinationType
    public typealias TabType = PresentationConfiguration.TabType
    public typealias PresentationType = PresentationType
    public typealias ContentType = PresentationConfiguration.ContentType
    public typealias PresentationConfiguration = PresentationConfiguration
   
    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?
    
    public var supportsIgnoringCurrentDestinationStatus: Bool = false

    public init() {}

}
