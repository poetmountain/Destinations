//
//  NavigationDestinationStateable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an interface's state object, holding a reference to its associated Destination and a navigator object which manages the state of the interface's navigation stack.
@MainActor public protocol NavigationDestinationStateable<Destination>: DestinationStateable {
    
    /// The navigator object which handles the state of the navigation stack associated with this user interface.
    var navigator: any DestinationPathNavigating { get set }
}
