//
//  DestinationInterfaceCoordinating.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
public typealias RemoveDestinationClosure = ((_ removalID: UUID) -> Void)

/// This protocol defines methods that an object should implement to receive updates from ``DestinationInterfaceCoordinator`` objects.
public protocol DestinationInterfaceCoordinatorDelegate: AnyObject {
    
    /// Notifies the delegate object when the currently presented Destination was requested to change.
    /// - Parameter newDestinationID: The identifier of a new Destination to present.
    func didRequestCurrentDestinationChange(newDestinationID: UUID)
}

/// This abstract protocol represents an object that coordinates the presentation of a Destination within a UI framework.
public protocol DestinationInterfaceCoordinating {
    
    /// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
    var removeDestinationClosure: RemoveDestinationClosure? { get set }
    
    /// A delegate protocol object which can subscribe to this object to receive updates about the status of destination presentations.
    var delegate: DestinationInterfaceCoordinatorDelegate? { get set }
    
    /// The Destination that currently should be presented.
    var destinationToPresent: (any Destinationable)? { get set }
    
}




