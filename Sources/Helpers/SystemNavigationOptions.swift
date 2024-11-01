//
//  SystemNavigationOptions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.


import Foundation

/// This model is used to send data with system navigation events.
public struct SystemNavigationOptions {
    
    /// The identifier of the target Destination.
    public var targetID: UUID?
    
    /// The identifier of the parent Destination.
    public var parentID: UUID?
    
    /// The identifier of the currently presented Destination.
    public var currentID: UUID?
    
    /// The initializer.
    /// - Parameters:
    ///   - targetID: The identifier of the target Destination.
    ///   - currentID: The identifier of the currently presented Destination.
    ///   - parentID: The identifier of the parent Destination.
    public init(targetID: UUID? = nil, currentID: UUID? = nil, parentID: UUID? = nil) {
        self.targetID = targetID
        self.currentID = currentID
        self.parentID = parentID
    }
}
