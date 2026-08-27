//
//  InteractorResultHandling.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines an interface for performing Interactor requests and handling their results.
///
/// Conforming types are generally type-erased Destinations that dispatch requests to Interactors and process the `Result` objects that their operations return. This allows Interactor assistants to be reused across different Destination objects instead of being tightly coupled to one.
@MainActor
public protocol InteractorResultHandling<InteractorType, ContentType>: Sendable, AnyObject {
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    associatedtype ContentType: ContentTypeable
    
    
    /// Handles the result of an Interactor request in a synchronous context.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request)
    
    /// Handles the result of an async Interactor request.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async
    
    /// Performs a request with the specified Interactor.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request)
    
    /// Performs a request with the specified Interactor asynchronously.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    /// - Returns: A `Result` containing an array of items.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<Request.ResultData, Error>
    
    /// Returns an Interactor for the specified type.
    /// - Parameter type: The enum type of an Interactor.
    /// - Returns: An Interactor, if one was found.
    func interactor(for type: InteractorType) -> (any AbstractInteractable)?
}
