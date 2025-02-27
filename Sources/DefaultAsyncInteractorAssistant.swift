//
//  DefaultAsyncInteractorAssistant.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A default assistant to be used to configure async interactor actions. This assistant only passes along the given action type with the request to the interactor.
public struct DefaultAsyncInteractorAssistant<InteractorType: InteractorTypeable, Request: InteractorRequestConfiguring, ContentType: ContentTypeable>: AsyncInteractorAssisting {
    
    public let interactorType: InteractorType
    
    public var actionType: Request.ActionType
    
    public var requestMethod: InteractorRequestMethod = .async
            
    public init(interactorType: InteractorType, actionType: Request.ActionType) {
        self.interactorType = interactorType
        self.actionType = actionType
    }
    
    public func handleAsyncRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) async where Destination.InteractorType == InteractorType {
        
        let request = Request(action: actionType)
        let result = await destination.performRequest(interactor: interactorType, request: request)
        await destination.handleInteractorResult(result: result, for: request)
            
    }
}
