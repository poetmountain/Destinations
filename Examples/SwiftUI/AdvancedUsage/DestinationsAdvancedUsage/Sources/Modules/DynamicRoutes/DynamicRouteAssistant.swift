//
//  DynamicRouteAssistant.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// This assistant is used to dynamically change the Destination type of a presentation request based on the content passed in with the request.
struct DynamicRouteAssistant<UserInteractionType: UserInteractionTypeable>: InterfaceActionConfiguring, DestinationTypes {
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id

        if case .route(let route) = content {
            closure.data.destinationType = route
            
        }
        
        return closure
    }
}
