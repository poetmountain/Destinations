//
//  DestinationPresentationTypeable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an enum which defines Destination presentation types.
@MainActor public protocol DestinationPresentationTypeable {
    
    /// The String representation of the enum type.
    var rawValue: String { get }
}
