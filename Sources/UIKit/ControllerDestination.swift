//
//  ControllerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A Destination class whose associated user interface is a `UIViewController`.
///
/// This is a generic Destination that can be used to represent most `UIViewController` subclasses in a UIKit-based app.
@Observable
public final class ControllerDestination<ControllerDestinationType: ControllerDestinationInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: ControllerDestinationable {
 
    public typealias ControllerType = ControllerDestinationType

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public let type: DestinationType
    
    /// The `UIViewController` class associated with this Destination.
    public var controller: ControllerType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    
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

extension ControllerDestination: Equatable {
    nonisolated public static func == (lhs: ControllerDestination, rhs: ControllerDestination) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension ControllerDestination: @preconcurrency CustomStringConvertible {
    public var description: String {
        return "\(Self.self) : \(type) : \(id)"
    }
}
