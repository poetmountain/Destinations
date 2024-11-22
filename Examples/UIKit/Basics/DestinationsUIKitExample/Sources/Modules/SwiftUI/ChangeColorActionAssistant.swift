//
//  ChangeColorActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class ChangeColorActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = ColorView.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id
        
        if case .changeColor = interactionType {
            if let content, closure.data.contentType == nil {
                closure.data.contentType = content
            }
        }
        
        return closure
    }
}
