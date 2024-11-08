//
//  SwiftUIAdaptable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an object that adapts a SwiftUI `View` for use inside a `UIViewController`.
@MainActor public protocol SwiftUIAdaptable {
    /// The type of SwiftUI `View` to adapt.
    associatedtype Content: ViewDestinationInterfacing
    
    /// The SwiftUI `View` to adapt.
    var view: Content { get set }
}
