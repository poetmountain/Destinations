//
//  DestinationInternalState.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This class holds the internal state of classes conforming to the ``Destinationable`` protocol.
public final class DestinationInternalState<UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: DestinationInternalStateable {
    
    /// The identifier of this object's parent Destination.
    public var parentDestinationID: UUID?

    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    public var destinationConfigurations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>?
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    public var systemNavigationConfigurations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?
    
    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    public var isSystemNavigating: Bool = false
    
    public var interactors: [InteractorType : any AbstractInteractable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<InteractorType, ContentType>] = [:]

    public init() {}
}
