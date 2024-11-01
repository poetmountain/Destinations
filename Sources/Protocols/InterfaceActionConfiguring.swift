//
//  InterfaceActionConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an assistant which configures an ``InterfaceAction`` object that should present a Destination. This is typically used in conjunction with a Destination such as ``ControllerDestination`` or ``ViewDestination``.
@MainActor public protocol InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType> {
    
    /// An enum which defines user interaction types for a Destination.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// Configures and returns an interface action.
    /// - Parameters:
    ///   - interfaceAction: The ``InterfaceAction`` object to configure and run.
    ///   - interactionType: The type of user interaction.
    ///   - destination: The Destination object associated with the user interaction, used for configuring the ``InterfaceAction`` object.
    ///   - content: Optional content to use when performing the ``InterfaceAction``.
    /// - Returns: The configured interface action.
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<UserInteractionType, DestinationType, ContentType>
}
