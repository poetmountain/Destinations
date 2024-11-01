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
public protocol DestinationConfigurationsContaining<UserInteractionType, DestinationType, TabType, PresentationConfiguration, ContentType> {
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    
    /// A dictionary of presentation configurations, using their associated user interaction types as keys.
    var configurations: [UserInteractionType: PresentationConfiguration] { get set }
        
    /// Adds a presentation configuration to this object's `configurations` dictionary.
    /// - Parameters:
    ///   - configuration: A presentation configuration to add.
    ///   - interactionType: The user interaction type to associate with this presentation.
    func addConfiguration(configuration: PresentationConfiguration, for interactionType: UserInteractionType)
    
    /// Returns a presentation configuration object, or `nil` if one isn't found.
    /// - Parameter interactionType: The user interaction type associated with the configuration object to be found.
    /// - Returns: A `PresentationConfiguration` object, or `nil` if the specified object was not found.
    func configuration(for interactionType: UserInteractionType) -> PresentationConfiguration?
    
    /// Removes all presentation configuration objects held in this object.
    func removeAllConfigurations()
}

