//
//  NavigationViewDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation


/// A Destination class whose associated user interface is a `View` which contains a `NavigationStack`.
///
/// This is a generic Destination that can be used to represent most `NavigationStack`-based `View`s in a SwiftUI-based app.
@Observable public final class NavigationViewDestination<UserInteractionType: UserInteractionTypeable, ViewDestinationType: NavigatingDestinationInterfacing, PresentationConfigurationType: DestinationPresentationConfiguring, InteractorType: InteractorTypeable>: NavigatingViewDestinationable {

    /// An enum which defines all routable Destinations in the app.
    public typealias DestinationType = PresentationConfigurationType.DestinationType
    
    /// An enum which defines types of tabs in a tab bar.
    public typealias TabType = PresentationConfigurationType.TabType
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    public typealias ContentType = PresentationConfigurationType.ContentType
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    public typealias InteractorType = InteractorType
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    public typealias PresentationConfiguration = PresentationConfigurationType
    
    /// An enum which defines user interaction types for this Destination's interface.
    public typealias UserInteractionType = UserInteractionType
    
    /// The type of `View` associated with this Destination.
    public typealias ViewType = ViewDestinationType
    
    public let id = UUID()
    
    public let type: DestinationType
    
    public var view: ViewType?

    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<NavigationViewDestination>] = [:]

    
    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?

    private(set) var listID: UUID = UUID()

    public var isSystemNavigating: Bool = false
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.type = destinationType
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }

}
