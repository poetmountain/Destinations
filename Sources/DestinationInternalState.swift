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
public final class DestinationInternalState<InteractorType: InteractorTypeable, UserInteractionType: UserInteractionTypeable, PresentationType: DestinationPresentationTypeable, PresentationConfiguration: DestinationPresentationConfiguring>: DestinationInternalStateable {
    
    public typealias UserInteractionType = UserInteractionType
    public typealias DestinationType = PresentationConfiguration.DestinationType
    public typealias InteractorType = InteractorType
    public typealias TabType = PresentationConfiguration.TabType
    public typealias PresentationType = PresentationType
    public typealias ContentType = PresentationConfiguration.ContentType
    public typealias PresentationConfiguration = PresentationConfiguration
    
    
    /// The identifier of this object's parent Destination.
    public var parentDestinationID: UUID?

    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    public var destinationConfigurations: DestinationConfigurations?
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    public var isSystemNavigating: Bool = false

    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, PresentationConfiguration.DestinationType, PresentationConfiguration.ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, PresentationConfiguration.DestinationType, PresentationConfiguration.ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<InteractorType, PresentationConfiguration.ContentType>] = [:]

    public init() {}
}
