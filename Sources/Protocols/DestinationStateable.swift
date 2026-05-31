//
//  DestinationStateable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an interface's state object which holds a reference to its associated Destination.
@MainActor public protocol DestinationStateable<Destination, StateModel>: AnyObject {
    
    /// The Destination class type associated with this state's Destination.
    associatedtype Destination: Destinationable
    
    /// The state model object type to be used with this Destination's interface.
    associatedtype StateModel
    
    /// A reference to the Destination object.
    var destination: Destination { get set }
    
    /// The state model used with this Destination's interface. It holds the interface's state, along with handling business logic and interactor requests and responses.
    var stateModel: StateModel { get set }
}
