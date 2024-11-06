//
//  DestinationNavigator.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This class brings SwiftUI's `NavigationStack` into the Destinations ecosystem, handling the state of the stack.
@Observable
public final class DestinationNavigator: DestinationPathNavigating {
    
    /// An array of `UUID` identifiers representing Destinations in the associated navigation path.
    public var navigationPath: [UUID] = []
    
    /// The identifier of the current destination presentation.
    public var currentPresentationID: UUID?
    
    /// The identifier of the Destination associated with this navigator.
    public var navigatorDestinationID: UUID?
    
    /// The initializer.
    /// - Parameter navigationPath: An array of `UUID` identifiers representing Destinations in the associated navigation path.
    public init(navigationPath: [UUID]? = nil) {
        if let navigationPath = navigationPath {
            self.navigationPath = navigationPath
        }
    }
    
    public func addPathElement(item: UUID, shouldAnimate: Bool? = true) {
        let shouldAnimate = shouldAnimate ?? true
        
        var transaction = Transaction()
        transaction.disablesAnimations = !shouldAnimate
        withTransaction(transaction) {
            self.navigationPath.append(item)
        }
    }
}
