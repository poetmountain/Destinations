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
public final class NavigationControllerDestination<ControllerDestinationType: NavigationControllerDestinationInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigatingControllerDestinationable {

    public typealias ControllerType = ControllerDestinationType

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The `UIViewController` class associated with this Destination.
    public var controller: ControllerType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()


    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.type = destinationType
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations

    }

    public func prepareForPresentation() {
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
