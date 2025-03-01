//
//  InteractorAssisting.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an assistant which helps a Destination make requests of an Interactor. Concrete assistants conforming to this protocol should handle requests for a specific Interactor type.
@MainActor public protocol InteractorAssisting<InteractorType, ContentType> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// A configuration model which defines an Interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
    /// A content type associated with the Interactor.
    associatedtype ContentType: ContentTypeable
    
    /// The type of Interactor.
    var interactorType: InteractorType { get }
    
    /// The type of action requested of the Interactor.
    var actionType: Request.ActionType { get }
    
    /// A type that represents whether the Interactor request should be made using concurrency or not.
    var requestMethod: InteractorRequestMethod { get }
      
    /// Handles a request to an Interactor. Responses to the Interactor should be handled using the ``completionClosure`` closure.
    /// - Parameter destination: The Destination which the Interactor is associated with. This reference is used to make requests to the Interactor.
    /// - Parameter content: An optional content model used to make a request to the Interactor.
    func handleRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) where Destination.InteractorType == InteractorType
}

public extension InteractorAssisting {
    var requestMethod: InteractorRequestMethod { .sync }
}
