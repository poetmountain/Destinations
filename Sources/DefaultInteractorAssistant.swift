//
//  DefaultInteractorAssistant.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A default assistant to be used to configure interactor actions. This assistant only passes along the given action type with the request to the interactor.
public struct DefaultInteractorAssistant<InteractorType: InteractorTypeable, Request: InteractorRequestConfiguring, ContentType: ContentTypeable>: InteractorAssisting {
    
    public let interactorType: InteractorType
    
    public var actionType: Request.ActionType
    
    public var requestMethod: InteractorRequestMethod = .async
            
    public init(interactorType: InteractorType, actionType: Request.ActionType) {
        self.interactorType = interactorType
        self.actionType = actionType
    }
    
    public func handleRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) where InteractorType == Destination.InteractorType {
        
        let request = Request(action: actionType)
        destination.performRequest(interactor: interactorType, request: request)
        
    }

}
