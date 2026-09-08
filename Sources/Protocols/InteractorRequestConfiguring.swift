//
//  InteractorRequestConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an Interactor configuration model which defines a request to perform an action.
public protocol InteractorRequestConfiguring: Sendable {
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// The type of content that is sent with a request to an interactor.
    associatedtype RequestContentType: ContentTypeable
    
    /// An enum type representing the type of data that is returned from an interactor.
    associatedtype ResultData: ContentTypeable
    
    /// The type of action to request being performed.
    var action: ActionType { get }

    init(action: ActionType)

    /// Creates a request carrying optional content alongside the action to perform. The default assistants (``DefaultInteractorAssistant`` and ``DefaultAsyncInteractorAssistant``) call this when building a request, so a conforming type only needs to implement this initializer and handle the content there if the request should incorporate content passed into the assistant.
    /// - Parameters:
    ///   - action: The type of action to request being performed.
    ///   - content: Optional content to incorporate into the request.
    init(action: ActionType, content: RequestContentType?)
}

public extension InteractorRequestConfiguring {
    /// The default implementation ignores `content` and defers to ``init(action:)``. Override this if the request should incorporate content passed into the assistant.
    init(action: ActionType, content: RequestContentType?) {
        self.init(action: action)
    }
}

/// This protocol represents an enum which defines types of actions for a particular Interactor.
public protocol InteractorRequestActionTypeable: Hashable, Sendable {}
