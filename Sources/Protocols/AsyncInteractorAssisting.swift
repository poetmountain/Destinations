//
//  AsyncInteractorAssisting.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an assistant which helps a Destination make requests of an interactor which participates in async/await flows. Concrete assistants conforming to this protocol should handle requests for a specific interactor type.
@MainActor public protocol AsyncInteractorAssisting<InteractorType, ContentType>: InteractorAssisting {
    
    /// Handles an async request to an interactor.
    /// - Parameter destination: The Destination which the interactor is associated with. This reference is used to make requests to the interactor.
    /// - Parameter content: An optional content model used to make a request to the interactor.
    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) async where Destination.InteractorType == InteractorType

}

public extension AsyncInteractorAssisting {
    func handleRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) where Destination.InteractorType == InteractorType {}
}
