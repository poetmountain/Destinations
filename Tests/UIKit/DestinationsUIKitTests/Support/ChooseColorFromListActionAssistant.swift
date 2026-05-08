//
//  ChooseColorFromListActionAssistant.swift
//  DestinationsUIKit
//
//  Created by Brett Walker on 2/25/25.
//

import UIKit
@testable import DestinationsUIKit
import Destinations

final class ChooseColorFromListActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = TestColorsDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
                
        closure.data.parentID = destination.parentDestinationID()
        
        
        if let content {
            closure.data.contentType = content
        }
        
        return closure
    }
}
