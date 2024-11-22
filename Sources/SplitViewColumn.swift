//
//  SplitViewColumn.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A model used to facilitate UIKit and SwiftUI presentations of a Destination in a split view interface.
public struct SplitViewColumn {
    
#if canImport(UIKit)
    /// Represents a column type in a `UISplitViewController`.
    public var uiKit: UISplitViewController.Column?
#endif
    
#if canImport(SwiftUI)
    /// A model representing a `NavigationSplitView` column.
    public var swiftUI: NavigationSplitViewColumn?
#endif
    
#if canImport(UIKit)
    
    /// An initializer for `UISplitViewController`.
    /// - Parameter uiKit: Represents a column type in a `UISplitViewController`.
    public init(uiKit: UISplitViewController.Column? = nil) {
        self.uiKit = uiKit
    }
#endif
    
#if canImport(SwiftUI)
    
    /// An initializer for `NavigationSplitView`.
    /// - Parameter swiftUI: Represents a column type in a `NavigationSplitView`.
    public init(swiftUI: NavigationSplitViewColumn? = nil) {
        self.swiftUI = swiftUI
    }
#endif
}
