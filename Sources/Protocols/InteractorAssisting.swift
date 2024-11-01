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
@MainActor public protocol InteractorAssisting<Destination> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// A configuration model which defines an interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
    /// A Destination type.
    associatedtype Destination: Destinationable
    
    /// The type of interactor.
    var interactorType: InteractorType { get }
    
    /// The type of action requested of the interactor.
    var actionType: Request.ActionType { get set }
    
    /// A type that represents whether the interactor request should be made using concurrency or not.
    var requestMethod: InteractorRequestMethod { get set }
    
    /// A completion closure used to handle an interactor response in a non-async request.
    var completionClosure: DatasourceResponseClosure<[Request.ResultData]>? { get set }
        
    /// Handles an async request to an interactor.
    /// - Parameter destination: The Destination which the interactor is associated with. This reference is used to make requests to the interactor.
    func handleAsyncRequest(destination: Destination) async
    
    /// Handles a non-async request to an interactor. Responses to the interactor should be handled using the ``completionClosure`` closure.
    /// - Parameter destination: The Destination which the interactor is associated with. This reference is used to make requests to the interactor.
    func handleRequest(destination: Destination)
}

public extension InteractorAssisting {
    func handleAsyncRequest(destination: Destination) async {}
    func handleRequest(destination: Destination) {}
}


