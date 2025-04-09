//
//  SwiftUIHostingState.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A state object for a SwiftUI `View` being hosted within a UIKit interface.
@Observable
public final class SwiftUIHostingState<Content: SwiftUIHostedInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: DestinationStateable {
    
    public typealias Destination = SwiftUIContainerDestination<Content, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    
    
    /// The container Destination which user interaction events are sent to.
    public var destination: Destination
    
    /// The initializer.
    /// - Parameter destination: The container Destination which user interaction events are sent to.
    public init(destination: Destination) {
        self.destination = destination
    }
}
