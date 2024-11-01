//
//  DestinationInterfaceState.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Manages state for a Destination's interface and holds a reference to it.
@Observable
public final class DestinationInterfaceState<Destination: Destinationable>: DestinationStateable {
    
    /// The Destination which user interaction events are sent to.
    public var destination: Destination
    
    /// The initializer.
    /// - Parameter destination: The Destination associated with this state model.
    public init(destination: Destination) {
        self.destination = destination
    }
}
