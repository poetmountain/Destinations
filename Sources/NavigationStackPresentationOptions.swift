//
//  NavigationStackPresentationOptions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An options model that configures how a Destination is presented within a navigation stack, either within a `NavigationStack` in SwiftUI or a `UINavigationController` in UIKit.
public struct NavigationStackPresentationOptions {
    
    /// Determines whether a Destination should be presented with an animation when added to a navigation stack. Setting this property to false will result in the default system animation not being shown when a Destination is added to a `NavigationStack` or `UINavigationController`.
    public var shouldAnimate: Bool = true
    
    /// The initializer.
    /// - Parameter shouldAnimate: Determines whether a Destination should be presented with an animation when added to a navigation stack.
    public init(shouldAnimate: Bool? = nil) {
        if let shouldAnimate {
            self.shouldAnimate = shouldAnimate
        }
    }
}
