//
//  ViewDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A Destination class whose associated user interface is a SwiftUI `View`.
///
/// This is a generic Destination that can be used to represent most `View`s in a SwiftUI-based app.
@Observable
public final class ViewDestination<ViewType: ViewDestinationInterfacing, EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: ViewDestinationable {

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The SwiftUI `View` class associated with this Destination.
    public var view: ViewType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()

    public var stateModel: (any StateModeling<ViewDestination<ViewType, EventType, DestinationType, ContentType, TabType, InteractorType>>)?

    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil, state: (any StateModeling<ViewDestination<ViewType, EventType, DestinationType, ContentType, TabType, InteractorType>>)? = nil) {
        self.type = destinationType
        self.stateModel = state
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations

    }
}

extension ViewDestination: Equatable {
    nonisolated public static func == (lhs: ViewDestination, rhs: ViewDestination) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension ViewDestination: @preconcurrency CustomStringConvertible {
    public var description: String {
        return "\(Self.self) : \(type) : \(id)"
    }
}
