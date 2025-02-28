//
//  ChooseColorFromListActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ChooseColorFromListActionAssistant: InterfaceActionConfiguring, AppDestinationTypes {
    typealias UserInteractionType = ColorsListDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?
                
        if case .color(model: let model) = interactionType {
            if let model {
                contentType = .color(model: model)
            }
            
            closure.data.contentType = contentType
            closure.data.parentID = destination.id
        }
        
        return closure
    }
}




