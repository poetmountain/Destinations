//
//  DefaultInteractorAssistant.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A default assistant to be used to configure Interactor actions. This assistant passes along the given action type and optional content with the request to the interactor. If the incoming content is the same type as the Request's `RequestContentType`, it's also passed to the request's ``InteractorRequestConfiguring/init(action:content:)`` initializer, otherwise no content is passed in.
public struct DefaultInteractorAssistant<InteractorType: InteractorTypeable, Request: InteractorRequestConfiguring, ContentType: ContentTypeable>: InteractorAssisting {

    public let interactorType: InteractorType

    public var requestMethod: InteractorRequestMethod = .async

    public init(interactorType: InteractorType) {
        self.interactorType = interactorType
    }

    public func handleRequest<Destination>(destination: Destination, actionType: Request.ActionType, content: ContentType?) where Destination : Destinationable, Destination.ContentType == ContentType, InteractorType == Destination.InteractorType {

        var typedContent: Request.RequestContentType?
        
        if let content = content, let requestContent = content as? Request.RequestContentType {
            typedContent = requestContent
        }
        
        let request = Request(action: actionType, content: typedContent)
        destination.performRequest(interactor: interactorType, request: request)

    }


}
