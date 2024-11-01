//
//  SwiftUIContainerInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents a controller that serves as a container for a SwiftUI `View`.
@MainActor public protocol SwiftUIContainerInterfacing<Content>: ControllerDestinationInterfacing, UIViewController where Destination: Destinationable {
    
    /// The SwiftUI `View` that is hosted by this controller.
    associatedtype Content: SwiftUIHostedInterfacing

    /// Reference to the SwiftUI `View` contained by this controller.
    var swiftUIView: Content { get }
    
    /// The adapter which holds the associated SwiftUI `View` and presents it in a `UIHostingController`.
    var adapter: SwiftUIAdapter<Content> { get }

}

