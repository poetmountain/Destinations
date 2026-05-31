//
//  NavigationControllerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A Destination class whose associated user interface is a `UINavigationController`.
///
/// This is a generic Destination that can be used to represent most `UINavigationController` classes in a UIKit-based app.
public final class NavigationControllerDestination<ControllerDestinationType: NavigationControllerDestinationInterfacing, EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigatingControllerDestinationable {

    public typealias ControllerType = ControllerDestinationType

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The `UIViewController` class associated with this Destination.
    public var controller: ControllerType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

    public var stateModel: (any StateModeling<NavigationControllerDestination<ControllerDestinationType, EventType, DestinationType, ContentType, TabType, InteractorType>>)?

    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil, state: (any StateModeling<NavigationControllerDestination<ControllerDestinationType, EventType, DestinationType, ContentType, TabType, InteractorType>>)? = nil) {
        self.type = destinationType
        self.stateModel = state
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations

    }
}

extension NavigationControllerDestination: Equatable {
    nonisolated public static func == (lhs: NavigationControllerDestination, rhs: NavigationControllerDestination) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension NavigationControllerDestination: @preconcurrency CustomStringConvertible {
    public var description: String {
        return "\(Self.self) : \(type) : \(id)"
    }
}

public final class DefaultNavigationController<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: UINavigationController, NavigationControllerDestinationInterfacing {
        
    public typealias Destination = DefaultNavigationControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>
    public typealias InteractorType = InteractorType
    public typealias EventType = EventType
    public typealias ControllerType = DefaultNavigationController
    public typealias StateModel = DefaultDestinationState<Destination>

    public var destinationState: NavigationDestinationInterfaceState<Destination>
        
    public init(destination: Destination, state: StateModel? = nil) {
        let state = state ?? DefaultDestinationState(destination: destination)
        self.destinationState = NavigationDestinationInterfaceState(destination: destination, state: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public final class DefaultNavigationControllerDestination<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigatingControllerDestinationable {

    public typealias ControllerType = DefaultNavigationController<EventType, DestinationType, ContentType, TabType, InteractorType>

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The `UIViewController` class associated with this Destination.
    public var controller: ControllerType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

    public var stateModel: (any StateModeling<DefaultNavigationControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>>)?

    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil, state: (any StateModeling<DefaultNavigationControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>>)? = nil) {
        self.type = destinationType
        self.stateModel = state
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations

    }

    public func prepareForPresentation() {
        stateModel?.prepareForPresentation()
    }
}
