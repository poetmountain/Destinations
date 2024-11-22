//
//  ColorDetailActionAssistant.swift
//  DestinationsUIKit
//
//  Created by Brett Walker on 11/21/24.
//

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
