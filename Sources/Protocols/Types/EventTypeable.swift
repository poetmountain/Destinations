//
//  EventTypeable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents enums which define event types associated with a Destination.
public protocol EventTypeable: Hashable, Equatable, CaseIterable {
    /// The String representation of the enum type.
    var rawValue: String { get }
}
