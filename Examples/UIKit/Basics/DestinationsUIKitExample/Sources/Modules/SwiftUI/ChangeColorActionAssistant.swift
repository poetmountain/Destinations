//
//  ChangeColorActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ChangeColorActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias EventType = ColorView.Events
    
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id
        
        if case .changeTab = eventType {
            if let content, closure.data.contentType == nil {
                closure.data.contentType = content
            }
        }
        
        return closure
    }
}
