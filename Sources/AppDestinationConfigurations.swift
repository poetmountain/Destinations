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
public final class AppDestinationConfigurations<UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>: DestinationConfigurationsContaining {
            
    
    /// A dictionary of presentation configuration objects, whose keys are a user interaction type they're associated with.
    public var configurations: [UserInteractionType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    
    /// Initializer.
    /// - Parameter configurations: A dictionary of presentation configuration objects, whose keys are a user interaction type they're associated with.
    public init(configurations: [UserInteractionType : DestinationPresentation<DestinationType, ContentType, TabType>]? = nil) {
        if let configurations {
            self.configurations = configurations
        }
    }
    
    /// Adds a presentation configuration to the specified user interaction type.
    /// - Parameters:
    ///   - configuration: The presentation configuration to add.
    ///   - interactionType: The user interaction type to associate with the presentation.
    public func addConfiguration(configuration: DestinationPresentation<DestinationType, ContentType, TabType>, for interactionType: UserInteractionType) {
        self.configurations[interactionType] = configuration
    }
    
    /// Returns a presentation configuration object based on its associated user interaction type.
    /// - Parameter interactionType: The user interaction type to find a configuration object for.
    /// - Returns: A presentation configuration, if one is found.
    public func configuration(for interactionType: UserInteractionType) -> DestinationPresentation<DestinationType, ContentType, TabType>? {
        return configurations[interactionType]
    }
    
    /// Removes all model objects from the ``configurations`` dictionary.
    public func removeAllConfigurations() {
        configurations.removeAll()
    }
}
