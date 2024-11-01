//
//  ChangeColorActionAssistant.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 9/26/24.
//

import Foundation
import Destinations

final class ChangeColorActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = ColorView.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        closure.data.parentID = destination.id
        
        if case .changeColor = interactionType {
            if let content, closure.data.contentType == nil {
                closure.data.contentType = content
            }
        }
        
        return closure
    }
}
