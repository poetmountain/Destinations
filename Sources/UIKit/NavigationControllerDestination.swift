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
public final class NavigationControllerDestination<UserInteractionType: UserInteractionTypeable, ControllerDestinationType: NavigationControllerDestinationInterfacing, PresentationConfigurationType: DestinationPresentationConfiguring, InteractorType: InteractorTypeable>: NavigatingControllerDestinationable {

    public typealias DestinationType = PresentationConfigurationType.DestinationType
    public typealias TabType = PresentationConfigurationType.TabType
    public typealias ContentType = PresentationConfigurationType.ContentType
    public typealias InteractorType = InteractorType
    public typealias PresentationConfiguration = PresentationConfigurationType
    public typealias UserInteractionType = UserInteractionType
    public typealias ControllerType = ControllerDestinationType


    /// A unique identifier.
    public let id = UUID()

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    public var type: DestinationType
    
    /// The `UIViewController` class associated with this Destination.
    public var controller: ControllerType?

    /// The identifier of this object's parent Destination.
    public var parentDestinationID: UUID?

    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    public var destinationConfigurations: DestinationConfigurations?
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    public var isSystemNavigating: Bool = false
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType : any InteractorAssisting<NavigationControllerDestination>] = [:]

    
    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
        self.type = destinationType

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
