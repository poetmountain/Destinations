//
//  ChooseColorFromListActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ChooseColorFromListActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias EventType = ColorsViewController.EventType
    
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?
                
        switch content {
            case .color(model: let model):
                
                contentType = .color(model: model)
                
                closure.data.contentType = contentType
                closure.data.parentID = destination.id
                
            default: break
        }
        
        if let contentType {
            closure.data.contentType = contentType
        }
        
        return closure
    }
}
