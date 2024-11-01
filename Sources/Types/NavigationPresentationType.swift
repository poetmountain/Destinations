//
//  NavigationPresentationType.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Defines presentation types for navigation stacks.
public enum NavigationPresentationType {
    /// Represents a presentation type where a new Destination is presented.
    case present
    
    /// Represents a presentation type where the previous Destination in the navigation stack is presented again.
    case goBack
}
