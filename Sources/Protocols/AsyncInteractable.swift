//
//  AsyncInteractable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an Interactor actor. Interactors provide an interface to perform some business logic, often acting as a datasource by interfacing with an API, handling system APIs, or some other self-contained work. For more information on interactors, see the documentation in ``Interactable``.
public protocol AsyncInteractable<Request, ResultData>: Actor, Interactable {
    
    /// A type representing the enum return type for the data this Interactor sends back.
    associatedtype ResultData: ContentTypeable
    
    /// Requests the Interactor to perform an async operation.
    /// - Parameter request: A configuration model which defines the request.
    /// - Returns: A `Result` which, if successful, returns the result data for the operation.
    func perform(request: Request) async -> Result<ResultData, Error>
    
    /// This method can be called to prepare the Interactor for requests. Typically you might want to call this from ``Destinationable``'s `configureInteractor()` method.
    func prepareForRequests()
}

public extension AsyncInteractable {
    /// This method can be called to prepare the Interactor for requests. Typically you might want to call this from ``Destinationable``'s `configureInteractor()` method.
    func prepareForRequests() {}
}
