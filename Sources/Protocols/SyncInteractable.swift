//
//  SyncInteractable.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents Interactors that handle requests using a synchronous context, typically providing results for requests via a ``InteractorResponseClosure``.
public protocol SyncInteractable<Request>: Interactable {
    
    /// A dictionary of Interactor request responses, whose keys are the Interactor action type they are associated with.
    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] { get set }

    /// Requests the Interactor to perform an operation.
    /// - Parameters:
    ///   - request: A configuration model which defines the request.
    func perform(request: Request)
    
    /// Assigns a response closure for an Interactor action type, which is called after the request has completed.
    /// - Parameters:
    ///   - response: The response closure to be called.
    ///   - action: The Interactor action type to be associated with this response.
    func assignResponseForAction(response: @escaping InteractorResponseClosure<Request>, for action: Request.ActionType)
    
    /// Returns a response closure for the specified Interactor action.
    /// - Parameter action: The interactor action to find a response for.
    /// - Returns: The response closure, if one was found.
    func responseForAction(action: Request.ActionType) -> InteractorResponseClosure<Request>?
    
    /// This method can be called to prepare the Interactor for requests. Typically you might want to call this from ``Destinationable``'s `configureInteractor()` method.
    func prepareForRequests()
}


public extension SyncInteractable {
    func assignResponseForAction(response: @escaping InteractorResponseClosure<Request>, for action: Request.ActionType) {
        self.requestResponses[action] = response
    }
    
    func responseForAction(action: Request.ActionType) -> InteractorResponseClosure<Request>? {
        return self.requestResponses[action]
    }
    
    /// This method can be called to prepare the interactor for requests. Typically you might want to call this from ``Destinationable``'s `configureInteractor()` method.
    func prepareForRequests() {}
}
