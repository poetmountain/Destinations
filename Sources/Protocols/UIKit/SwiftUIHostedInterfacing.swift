//
//  SwiftUIHostedInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a SwiftUI `View` that is hosted by a container controller within UIKit.
@MainActor public protocol SwiftUIHostedInterfacing: ViewDestinationInterfacing {
    
    /// A state object used to hold a reference to this view's associated UIKit Destination.
    var hostingState: SwiftUIHostingState<Self, UserInteractionType, DestinationType, ContentType, TabType, InteractorType> { get set }
    
}
