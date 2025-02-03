//
//  ChooseColorFromListActionAssistant.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ChooseColorFromListActionAssistant: InterfaceActionConfiguring, AppDestinationTypes {
    typealias UserInteractionType = ColorsListDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var routeType: RouteDestinationType?
        var contentType: ContentType?
        
        closure.data.parentID = destination.parentDestinationID
        
        switch interactionType {
            case .color(model: let model):
                routeType = RouteDestinationType.colorNav
                
                if let model {
                    contentType = .color(model: model)
                }
                
                closure.data.contentType = contentType
                closure.data.parentID = destination.id
                
            case .moreButton:
                break
        }
        
        
        if let contentType {
            closure.data.contentType = contentType
        }
        
        if let routeType {
            closure.data.destinationType = routeType
        }
        
        
        return closure
    }
}
