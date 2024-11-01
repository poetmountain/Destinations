//
//  DefaultActionAssistant.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A default assistant to be used to configure interface actions. This only adds the the current Destination's `id` as the `parentID` value.
public final class DefaultActionAssistant<UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable>: InterfaceActionConfiguring {
    
    /// The initializer.
    public init() {
    }
        
    public func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id
        
        return closure
    }
}
