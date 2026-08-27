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
        
    public var requestMethod: InteractorRequestMethod = .async
            
    public init(interactorType: InteractorType) {
        self.interactorType = interactorType
    }
    
    public func handleAsyncRequest<Destination>(destination: Destination, actionType: Request.ActionType, content: Request.ResultData?) async where Destination : Destinationable, InteractorType == Destination.InteractorType {

        let request = Request(action: actionType)
        let result = await destination.performRequest(interactor: interactorType, request: request)
        await destination.handleAsyncInteractorResult(result: result, for: request)

    }

    public func asyncRequest<Destination>(destination: Destination, actionType: Request.ActionType, content: Request.ResultData?) async -> Result<Request.ResultData, any Error> where Destination : InteractorResultHandling, InteractorType == Destination.InteractorType {

        let request = Request(action: actionType)
        return await destination.performRequest(interactor: interactorType, request: request)

    }
    
    #if swift(>=6.1)
    public func asyncRequest<Interactor: AsyncInteractable>(interactor: Interactor, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Interactor.Request == Request {

        let request = Request(action: actionType)
        return await interactor.perform(request: request)

    }
    #else
    // Prior to Swift 6.1, `AsyncInteractable.ResultData` is a standalone associated type rather than being defined as `Request.ResultData`, so `Interactor.Request == Request` doesn't imply the two match.
    public func asyncRequest<Interactor: AsyncInteractable>(interactor: Interactor, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Interactor.Request == Request, Interactor.ResultData == Request.ResultData {

        let request = Request(action: actionType)
        return await interactor.perform(request: request)

    }
    #endif
    
}
