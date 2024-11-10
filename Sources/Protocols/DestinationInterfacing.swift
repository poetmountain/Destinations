//
//  DestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol representing a user interface object that is handled by Destinations. This is typically a `View` in SwiftUI or a `UIViewController` in UIKit.
@MainActor public protocol DestinationInterfacing<PresentationConfiguration> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// A model type which configures Destination presentations, used to present Destinations from user interactions with this interface. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring
    
    /// The type of Destination associated with this user interface.
    associatedtype Destination: Destinationable<PresentationConfiguration>
    
    /// The state model associated with this interface's Destination.
    associatedtype DestinationState: DestinationStateable<Destination>

    /// The Destination associated with this UI element.
    var destinationState: DestinationState { get set }
    
    /// Returns the current Destination associated with this interface element.
    /// - Returns: The associated Destination.
    func destination() -> Destination
    
    /// When this method is called, this interface's Destination is about to be removed from the Flow. Any resource references should be removed and in-progress tasks should be stopped.
    func cleanupResources()
}

// optional method conformance
public extension DestinationInterfacing {    
        
    func destination() -> Destination {
        return self.destinationState.destination
    }

    func cleanupResources() {
    }
}
