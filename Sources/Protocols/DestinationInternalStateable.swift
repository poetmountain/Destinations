//
//  DestinationInternalStateable.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents classes which the internal state of classes conforming to the ``Destinationable`` protocol.
public protocol DestinationInternalStateable<InteractorType, UserInteractionType, DestinationType, TabType, ContentType> {
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable

    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, PresentationConfiguration>
    
    
    /// The identifier of this object's parent Destination.
    var parentDestinationID: UUID? { get set }
    
    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    var destinationConfigurations: DestinationConfigurations? { get set }
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    var systemNavigationConfigurations: NavigationConfigurations? { get set }

    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    var isSystemNavigating: Bool { get set }

    /// A dictionary of interactors, with the associated keys being their interactor type.
    var interactors: [InteractorType: any Interactable] { get set }
    
    /// A dictionary of ``InterfaceAction`` objects, with the key being the associated user interaction type.
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of system navigation interface actions which are run when certain system navigation events occur, with the key being the associated system navigation type.
    var systemNavigationActions: [SystemNavigationType: InterfaceAction<SystemNavigationType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of assistants which help the Destination make requests of an interactor, with the key being the associated user interaction type.
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<InteractorType, ContentType>] { get set }

}
