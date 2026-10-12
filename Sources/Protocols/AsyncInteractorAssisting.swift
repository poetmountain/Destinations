//
//  AsyncInteractorAssisting.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an assistant which helps a Destination make requests of an Interactor which participates in async/await flows. Concrete assistants conforming to this protocol should handle requests for a specific Interactor type.
@MainActor public protocol AsyncInteractorAssisting<InteractorType, ContentType>: InteractorAssisting {
    
    /// Handles an async request to an Interactor, calling ``Destinationable.handleAsyncInteractorResult`` to return the result of the operation.
    /// - Parameter destination: The Destination which the Interactor is associated with. This reference is used to make requests to the Interactor.
    /// - Parameter content: An optional content model used to make a request to the Interactor.
    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType

    /// Handles a request to an Interactor in an asychronous context.
    /// - Parameter destination: The Destination which the Interactor is associated with. This reference is used to make requests to the Interactor.
    /// - Parameter content: An optional content model used to make a request to the Interactor.
    /// - Returns: The Result of the Interactor request.
    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, any Error> where Destination.InteractorType == InteractorType
    
    /// Bridges a caller's type-erased `InteractorRequestActionTypeable` into this assistant's concrete `Request.ActionType`, calls the typed `asyncRequest(destination:actionType:content:)`, and converts the result into `ContentType`.
    ///
    /// If the Interactor's `Request.ResultData` type differs from `ContentType`, supply a `resultTransformer` to bridge between the two. When no transformer is supplied, this falls back to a direct cast, which succeeds for the common case where the two types are the same.
    ///
    /// This is the shared primitive used by both ``asyncRequestForAction(destination:actionType:content:resultTransformer:)`` (used by `Action`/sequence steps, which get their transformer from an `ActionConfiguration`) and `Destinationable.performAction(for:content:)` (which looks its transformer up by event type). Any caller that only has an erased `actionType` rather than this assistant's concrete `Request.ActionType` should use this method instead of calling `asyncRequest` directly.
    /// - Parameters:
    ///   - destination: The Destination which the Interactor is associated with. This reference is used to make requests to the Interactor.
    ///   - actionType: The Interactor action type to request be performed.
    ///   - content: Optional content to be used with the request.
    ///   - resultTransformer: An optional, type-erased transformer that converts the Interactor's raw result into `ContentType`.
    /// - Returns: The Result of the Interactor request.
    func resolveAsyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?, resultTransformer: ContentTransformerWrapper<ContentType>?) async -> Result<ContentType, any Error> where Destination.InteractorType == InteractorType

    /// Calls ``resolveAsyncRequest(destination:actionType:content:resultTransformer:)`` with the given `resultTransformer`. `Action` calls this method rather than `resolveAsyncRequest` directly, since `Action`'s `resultTransformer` comes from an `ActionConfiguration` step rather than a per-event-type lookup.
    /// - Parameters:
    ///   - destination: The Destination which the Interactor is associated with. This reference is used to make requests to the Interactor.
    ///   - actionType: The Interactor action type to request be performed.
    ///   - content: Optional content to be used with the request.
    ///   - resultTransformer: An optional, type-erased transformer that converts the Interactor's raw result into `ContentType`.
    /// - Returns: The Result of the Interactor request.
    func asyncRequestForAction<Destination: InteractorResultHandling>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?, resultTransformer: ContentTransformerWrapper<ContentType>?) async -> Result<ContentType, any Error> where Destination.InteractorType == InteractorType
}

public extension AsyncInteractorAssisting {
    var requestMethod: InteractorRequestMethod { .async }

    func handleRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) where Destination.InteractorType == InteractorType {}

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {

        let template = DestinationsSupport.errorMessage(for: .missingAsyncRequestImplementation(message: "hey"))
        let message = String(format: template, "\(actionType)")
        destination.logError(error: DestinationsError.incompatibleType(message: message))

    }
    
    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?) async where Destination.InteractorType == InteractorType {

        guard let actionType = actionType as? Request.ActionType else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(actionType)")
            destination.logError(error: DestinationsError.childDestinationNotFound(message: message))

            return
        }

        await handleAsyncRequest(destination: destination, actionType: actionType, content: content)
    }


    func resolveAsyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?, resultTransformer: ContentTransformerWrapper<ContentType>?) async -> Result<ContentType, any Error> where Destination.InteractorType == InteractorType {

        guard let actionType = actionType as? Request.ActionType else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(actionType)")
            return .failure(DestinationsError.incompatibleType(message: message))
        }

        let result = await asyncRequest(destination: destination, actionType: actionType, content: content)

        switch result {
            case .success(let rawResult):
                if let resultTransformer {
                    do {
                        return .success(try resultTransformer.transform(result: rawResult))
                    } catch {
                        return .failure(error)
                    }
                } else if let content = rawResult as? ContentType {
                    return .success(content)
                } else {
                    let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
                    let message = String(format: template, "\(actionType)")
                    return .failure(DestinationsError.incompatibleType(message: message))
                }

            case .failure(let error):
                return .failure(error)
        }
    }

    func asyncRequestForAction<Destination: InteractorResultHandling>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?, resultTransformer: ContentTransformerWrapper<ContentType>?) async -> Result<ContentType, any Error> where Destination.InteractorType == InteractorType {

        return await resolveAsyncRequest(destination: destination, actionType: actionType, content: content, resultTransformer: resultTransformer)
    }
    
    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, any Error> where Destination.InteractorType == InteractorType {
        
        let template = DestinationsSupport.errorMessage(for: .missingAsyncRequestImplementation(message: "hey"))
        let message = String(format: template, "\(actionType)")
        return .failure(DestinationsError.incompatibleType(message: message))
    }
 
}
