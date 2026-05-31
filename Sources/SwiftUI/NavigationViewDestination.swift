//
//  NavigationViewDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation


/// A Destination class whose associated user interface is a `View` which contains a `NavigationStack`.
///
/// This is a generic Destination that can be used to represent most `NavigationStack`-based `View`s in a SwiftUI-based app.
@Observable public final class NavigationViewDestination<EventType: EventTypeable, ViewType: NavigatingDestinationInterfacing, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigatingViewDestinationable {


    public let id = UUID()
    
    public let type: DestinationType
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

    public var stateModel: (any StateModeling<NavigationViewDestination<EventType, ViewType, DestinationType, ContentType, TabType, InteractorType>>)?

    private(set) var listID: UUID = UUID()
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil, state: (any StateModeling<NavigationViewDestination<EventType, ViewType, DestinationType, ContentType, TabType, InteractorType>>)? = nil) {
        self.type = destinationType
        self.stateModel = state
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

}
