//
//  SwiftUIContainerDestinationable.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents the Destination of a UIKit controller which hosts SwiftUI content.
public protocol SwiftUIContainerDestinationable<DestinationType, ContentType, TabType>: ControllerDestinationable {
    
    /// The `ViewFlow` which manages the `View` Destinations contained by the object conforming to this protocol.
    var viewFlow: ViewFlow<DestinationType, TabType, ContentType>? { get }
    
    /// Presents a SwiftUI `View` Destination within this container.
    /// > Note: This method is only called if the presentation's `presentationType` is a `navigationController()` or `splitView()` type. If the presentation's `presentationType` is a `splitView()`, this method will change it to a `.navigationController()` type before passing it on to the ``viewFlow``.
    /// - Parameter presentation: The Destination presentation representing the `View` to be presented.
    func presentDestination(presentation: DestinationPresentation<DestinationType, ContentType, TabType>)
}
