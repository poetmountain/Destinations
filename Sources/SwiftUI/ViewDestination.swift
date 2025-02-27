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
public final class ViewDestination<UserInteractionType: UserInteractionTypeable, ViewDestinationType: ViewDestinationInterfacing, PresentationConfiguration: DestinationPresentationConfiguring>: ViewDestinationable {

    /// An enum which defines all routable Destinations in the app.
    public typealias DestinationType = PresentationConfiguration.DestinationType
    
    /// An enum which defines types of tabs in a tab bar.
    public typealias TabType = PresentationConfiguration.TabType
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    public typealias ContentType = PresentationConfiguration.ContentType
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    public typealias InteractorType = ViewDestinationType.InteractorType
    
    /// The `View` associated with this Destination.
    public typealias ViewType = ViewDestinationType

    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The SwiftUI `View` class associated with this Destination.
    public var view: ViewDestinationType?

    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    

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
