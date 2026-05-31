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
    typealias EventType = ColorDetailViewController.EventType

    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?

        closure.data.parentID = destination.id

        switch content {
            case .color(model: let model):
                if closure.data.contentType == nil {
                    contentType = .color(model: model)
                }
                
            default: break
        }


        if let contentType = contentType {
            closure.data.contentType = contentType
        }
        
        
        return closure
    }
}
