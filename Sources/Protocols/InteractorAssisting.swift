//
//  InteractorAssisting.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an assistant which helps a Destination make requests of an interactor. Concrete assistants conforming to this protocol should handle requests for a specific interactor type.
@MainActor public protocol InteractorAssisting<InteractorType, ContentType> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// A configuration model which defines an interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
    /// A content type associated with the interactor.
    associatedtype ContentType: ContentTypeable
    
    /// The type of interactor.
    var interactorType: InteractorType { get }
    
    /// The type of action requested of the interactor.
    var actionType: Request.ActionType { get }
    
    /// A type that represents whether the interactor request should be made using concurrency or not.
    var requestMethod: InteractorRequestMethod { get }
      
    /// Handles a non-async request to an interactor. Responses to the interactor should be handled using the ``completionClosure`` closure.
    /// - Parameter destination: The Destination which the interactor is associated with. This reference is used to make requests to the interactor.
    /// - Parameter content: An optional content model used to make a request to the interactor.
    func handleRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) where Destination.InteractorType == InteractorType
}
