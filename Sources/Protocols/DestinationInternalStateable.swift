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
public protocol DestinationInternalStateable<UserInteractionType, DestinationType, TabType, ContentType, InteractorType> {
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable

    /// The identifier of this object's parent Destination.
    var parentDestinationID: UUID? { get set }
    
    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    var destinationConfigurations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>? { get set }
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    var systemNavigationConfigurations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>? { get set }

    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    var isSystemNavigating: Bool { get set }

    /// A dictionary of interactors, with the associated keys being their interactor type.
    var interactors: [InteractorType: any AbstractInteractable] { get set }
    
    /// A dictionary of ``InterfaceAction`` objects, with the key being the associated user interaction type.
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of system navigation interface actions which are run when certain system navigation events occur, with the key being the associated system navigation type.
    var systemNavigationActions: [SystemNavigationType: InterfaceAction<SystemNavigationType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of assistants which help the Destination make requests of an interactor, with the key being the associated user interaction type.
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<InteractorType, ContentType>] { get set }

    /// A reference to the associated navigator object, if this Destination was presented within a SwiftUI `NavigationStack` or a custom navigation object.
    /// - Note: This property is unused with UIKit navigation controllers.
    var navigator: (any DestinationPathNavigating)? { get set }
}
