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
    typealias EventType = TestColorsViewController.EventType
    
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var closure = interfaceAction
                
        closure.data.parentID = destination.parentDestinationID()
        
        
        if let content {
            closure.data.contentType = content
        }
        
        return closure
    }
}
