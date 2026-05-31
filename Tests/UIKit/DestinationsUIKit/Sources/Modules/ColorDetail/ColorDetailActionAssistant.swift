//
//  ColorDetailActionAssistant.swift
//  DestinationsUIKit
//
//  Created by Brett Walker on 11/21/24.
//

import UIKit
import Destinations

final class ColorDetailActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias EventType = ColorDetailDestination.Events
    
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var contentType: ContentType?

        closure.data.parentID = destination.id

        switch eventType {
            case .colorDetailButton(model: let model):
                if let model, closure.data.contentType == nil {
                    contentType = .color(model: model)
                }
            case .moveToNearest:
                print("moving to nearest..")
                break
        }


        if let contentType = contentType {
            closure.data.contentType = contentType
        }
        
        
        return closure
    }
}
