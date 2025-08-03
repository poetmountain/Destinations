//
//  AbstractInteractable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This is an abstract protocol representing an Interactor object and Interactor objects should not conform to this directly.
///
/// > Important: This is an abstract protocol and Interactor objects should not conform to this directly. For Interactors running in a synchronous context where closures will provide operation results, please conform to ``Interactable``. If you need your Interactor to run as an Actor in an async context, please conform to ``AsyncInteractable``. And if your Interactor needs to represent a datasource for model retrieval, please use the ``Datasourceable`` or ``AsyncDatasourceable`` based on the context it should run in.
public protocol AbstractInteractable<Request>: AnyObject {
    
    /// A configuration model which defines an Interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
    /// This method can be called to prepare the Interactor for requests. Typically you might want to call this from ``Destinationable``'s `configureInteractor()` method.
    func prepareForRequests()
    
    /// When this method is called, this Interactor's Destination is about to be removed from the Flow. You can implement this method in your Interactors to remove any resource references and stop any in-progress tasks.
    func cleanupResources()
}

public extension AbstractInteractable {
    func prepareForRequests() {}
    func cleanupResources() {}
}

/// A generic closure which provides a result to an Interactor request.
///
/// This closure is generally used with Interactors conforming to ``Interactable``, which runs in a synchronous context. It provides both the result data and the original request object.
public typealias InteractorResponseClosure<Request: InteractorRequestConfiguring> = (_ result: Result<Request.ResultData, Error>, _ request: Request) -> Void
