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
public final class SwiftUIHostingState<Content: SwiftUIHostedInterfacing, EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigationDestinationStateable {
    
    public typealias Destination = SwiftUIContainerDestination<Content, EventType, DestinationType, ContentType, TabType, InteractorType>
    public typealias StateModel = DefaultDestinationState<Destination>

    
    /// The container Destination which user interaction events are sent to.
    public var destination: Destination
    
    /// An object which manages the state of the associated interface's navigation stack.
    public var navigator: any DestinationPathNavigating = DestinationNavigator()
    
    public var stateModel: DefaultDestinationState<Destination>

    /// The initializer.
    /// - Parameter destination: The container Destination which user interaction events are sent to.
    public init(destination: Destination, state: StateModel? = nil) {
        self.destination = destination
        self.stateModel = state ?? DefaultDestinationState(destination: destination)
    }
}
