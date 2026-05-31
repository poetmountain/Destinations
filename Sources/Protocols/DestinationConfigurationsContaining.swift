//
//  DestinationConfigurationsContaining.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an object that holds Destination presentation objects.
public protocol DestinationConfigurationsContaining<EventType, DestinationType, TabType, ContentType> {
    
    /// An enum which defines event types for this Destination's interface.
    associatedtype EventType: EventTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
   // typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    
    /// A dictionary of presentation configurations, using their associated event types as keys.
    var configurations: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] { get set }
        
    /// A dictionary of interactor request configurations, using their associated event types as keys.
    var interactorConfigurations: [EventType: any InteractorConfiguring] { get set }
    
    /// Adds a presentation configuration to this object's `configurations` dictionary.
    /// - Parameters:
    ///   - configuration: A presentation configuration to add.
    ///   - eventType: The event type to associate with this presentation.
    func addConfiguration(configuration: DestinationPresentation<DestinationType, ContentType, TabType>, for eventType: EventType)
    
    /// Adds an interactor request configuration to this object's `interactorConfigurations` dictionary.
    /// - Parameters:
    ///   - configuration: An interactor request configuration to add.
    ///   - eventType: The event type to associate with this interactor request.
    func addInteractorConfiguration(configuration: any InteractorConfiguring, for eventType: EventType)
    
    /// Returns a presentation configuration object, or `nil` if one isn't found.
    /// - Parameter eventType: The event type associated with the configuration object to be found.
    /// - Returns: A `DestinationPresentation` object, or `nil` if the specified object was not found.
    func configuration(for eventType: EventType) -> DestinationPresentation<DestinationType, ContentType, TabType>?
    
    /// Returns an interactor request configuration object, or `nil` if one isn't found.
    /// - Parameter eventType: The event type associated with the configuration object to be found.
    /// - Returns: An object conforming to the `InteractorConfiguring` protocol, or `nil` if the specified object was not found.
    func interactorConfiguration(for eventType: EventType) -> (any InteractorConfiguring)?
    
    /// Removes all configurations held in this object.
    func removeAllConfigurations()
}

