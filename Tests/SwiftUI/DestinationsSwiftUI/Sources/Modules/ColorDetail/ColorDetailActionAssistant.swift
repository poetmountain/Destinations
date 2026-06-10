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
    typealias EventType = ColorDetailInterfaceState.Events
    
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?

        closure.data.parentID = destination.parentDestinationID()

        if let contentType = contentType {
            closure.data.contentType = contentType
        }
        
        
        return closure
    }
}
