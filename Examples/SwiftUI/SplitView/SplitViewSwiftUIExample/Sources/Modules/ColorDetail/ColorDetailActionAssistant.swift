//
//  ColorDetailActionAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorDetailActionAssistant: InterfaceActionConfiguring, AppDestinationTypes {
    typealias EventType = ColorDetailView.EventType

    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {

        var closure = interfaceAction

        closure.data.parentID = destination.id

        if let contentType = content {
            closure.data.contentType = contentType
        }


        return closure
    }
}
