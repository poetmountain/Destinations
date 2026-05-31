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
    public typealias StateModel = DefaultDestinationState<Destination>

    /// The Destination which events are sent to.
    public var destination: Destination
    
    /// The state model used with this Destination's interface. It holds the interface's state, along with handling business logic and interactor requests and responses.
    public var stateModel: StateModel

    /// The initializer.
    /// - Parameter destination: The Destination associated with this state model.
    public init(destination: Destination, state: StateModel? = nil) {
        self.destination = destination
        self.stateModel = state ?? DefaultDestinationState(destination: destination)
    }
}


