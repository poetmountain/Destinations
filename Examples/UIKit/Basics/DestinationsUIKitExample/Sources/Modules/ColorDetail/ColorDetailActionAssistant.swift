//
//  ColorDetailActionAssistant.swift
//  DestinationsUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorDetailActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?

        closure.data.parentID = destination.id

        switch interactionType {
            case .colorDetailButton(model: let model), .customDetailButton(model: let model):
                if let model, closure.data.contentType == nil {
                    contentType = .color(model: model)
                }
            case .color:
                break
        }


        if let contentType = contentType {
            closure.data.contentType = contentType
        }
        
        
        return closure
    }
}
