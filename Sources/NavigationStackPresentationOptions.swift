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
    public var shouldAnimate: Bool = true
    
    public init(shouldAnimate: Bool? = nil) {
        if let shouldAnimate {
            self.shouldAnimate = shouldAnimate
        }
    }
}
