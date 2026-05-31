//
//  NavigationDestinationInterfaceState.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Manages state for a Destination's interface, holding a reference to its associated Destination and a navigator object which manages the state of the interface's navigation stack.
@Observable
public final class NavigationDestinationInterfaceState<Destination: Destinationable>: NavigationDestinationStateable {
    public typealias StateModel = DefaultDestinationState<Destination>
    
    /// The Destination which events are sent to.
    public var destination: Destination
    
    /// An object which manages the state of the associated interface's navigation stack.
    public var navigator: any DestinationPathNavigating = DestinationNavigator()
    
    public var stateModel: StateModel
    
    /// The initializer.
    /// - Parameter destination: The Destination associated with this state model.
    public init(destination: Destination, state: StateModel? = nil) {
        self.destination = destination
        self.stateModel = state ?? DefaultDestinationState(destination: destination)
        navigator.navigatorDestinationID = destination.id
    }
}

