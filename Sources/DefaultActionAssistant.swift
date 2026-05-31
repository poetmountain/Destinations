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
public final class DefaultActionAssistant<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable>: InterfaceActionConfiguring {
    
    /// The initializer.
    public init() {
    }
        
    public func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id
        if closure.data.contentType == nil {
            closure.data.contentType = content
        }
        
        return closure
    }
}
