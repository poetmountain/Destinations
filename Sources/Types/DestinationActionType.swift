//
//  DestinationActionType.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// The type of action that a presentation should take. Currently this is only either a normal Destination presentation or a system navigation.
public enum DestinationActionType {
    /// Represents a Destination presentation.
    case presentation
    
    /// Represents a system-level navigation event.
    case systemNavigation
}
