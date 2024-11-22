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
@MainActor public protocol DestinationStateable<Destination>: AnyObject {
    
    /// The Destination type associated with this state model.
    associatedtype Destination: Destinationable
    
    /// A reference to the Destination object.
    var destination: Destination { get set }
}
