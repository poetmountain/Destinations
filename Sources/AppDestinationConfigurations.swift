//
//  AppDestinationConfigurations.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A container class for Destination presentation configuration models, which are used by a Destination to present new Destinations.
public final class AppDestinationConfigurations<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>: DestinationConfigurationsContaining {
            
    
    /// A dictionary of presentation configuration objects, whose keys are an event type they're associated with.
    public var configurations: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    
    /// A dictionary of interactor request configuration objects, whose keys are an event type they're associated with.
    public var interactorConfigurations: [EventType: any InteractorConfiguring] = [:]

    /// Initializer.
    /// - Parameter configurations: A dictionary of presentation configuration objects, whose keys are an event type they're associated with.
    public init(configurations: [EventType : DestinationPresentation<DestinationType, ContentType, TabType>]? = nil, interactorConfigurations: [EventType: any InteractorConfiguring]? = nil) {
        if let configurations {
            self.configurations = configurations
        }
        if let interactorConfigurations {
            self.interactorConfigurations = interactorConfigurations
        }
    }
    
    /// Adds a presentation configuration to the specified event type.
    /// - Parameters:
    ///   - configuration: The presentation configuration to add.
    ///   - eventType: The event type to associate with the presentation.
    public func addConfiguration(configuration: DestinationPresentation<DestinationType, ContentType, TabType>, for eventType: EventType) {
        self.configurations[eventType] = configuration
    }
    
    public func addInteractorConfiguration(configuration: any InteractorConfiguring, for eventType: EventType) {
        self.interactorConfigurations[eventType] = configuration
    }
    
    /// Returns a presentation configuration object based on its associated event type.
    /// - Parameter eventType: The event type to find a configuration object for.
    /// - Returns: A presentation configuration, if one is found.
    public func configuration(for eventType: EventType) -> DestinationPresentation<DestinationType, ContentType, TabType>? {
        return configurations[eventType]
    }
    
    public func interactorConfiguration(for eventType: EventType) -> (any InteractorConfiguring)? {
        return interactorConfigurations[eventType]
    }
    
    /// Removes all model objects from the ``configurations`` dictionary.
    public func removeAllConfigurations() {
        configurations.removeAll()
        interactorConfigurations.removeAll()
    }
}
