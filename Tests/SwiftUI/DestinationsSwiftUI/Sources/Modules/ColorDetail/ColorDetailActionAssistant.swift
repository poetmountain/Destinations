//
//  ColorDetailActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class ColorDetailActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?

        closure.data.parentID = destination.parentDestinationID()

        switch interactionType {
            case .color(model: let model):
                if let colorModel = model.color {
                    contentType = .color(model: colorModel)
                }
                if let targetID = model.targetID {
                    closure.data.actionTargetID = targetID
                }
            case .goBack:
                break
        }


        if let contentType = contentType {
            closure.data.contentType = contentType
        }
        
        
        return closure
    }
}
