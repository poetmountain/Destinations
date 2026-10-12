//
//  DefaultAsyncInteractorAssistant.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A default assistant to be used to configure async interactor actions. This assistant passes along the given action type and optional content along with the request to the Interactor. If the incoming content is the same type as the Request's `RequestContentType`, it is also passed to the request's ``InteractorRequestConfiguring/init(action:content:)`` initializer, otherwise no content is passed in.
///
/// If the Interactor's `Request.RequestContentType`/`Request.ResultData` differ from `ContentType`, supply `inputTransformer`/`outputTransformer` to bridge them instead of relying on the direct cast — this is what backs ``InteractorAssistantType/transformer(request:result:)``.
public struct DefaultAsyncInteractorAssistant<InteractorType: InteractorTypeable, Request: InteractorRequestConfiguring, ContentType: ContentTypeable>: AsyncInteractorAssisting {

    public let interactorType: InteractorType

    public var requestMethod: InteractorRequestMethod = .async

    /// Converts `ContentType` into `Request.RequestContentType` before a request is made. When `nil`, a direct cast is attempted instead, which succeeds when the two types are the same.
    private let inputTransformer: (any ContentTransformable<ContentType, Request.RequestContentType>)?

    /// Converts `Request.ResultData` into `ContentType` after a request completes. When `nil`, a direct cast is attempted instead, which succeeds when the two types are the same.
    private let outputTransformer: (any ContentTransformable<Request.ResultData, ContentType>)?

    public init(interactorType: InteractorType, inputTransformer: (any ContentTransformable<ContentType, Request.RequestContentType>)? = nil, outputTransformer: (any ContentTransformable<Request.ResultData, ContentType>)? = nil) {
        self.interactorType = interactorType
        self.inputTransformer = inputTransformer
        self.outputTransformer = outputTransformer
    }

    public func handleAsyncRequest<Destination>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination : Destinationable, InteractorType == Destination.InteractorType {

        let typedContent = typedRequestContent(from: content)
        let request = Request(action: actionType, content: typedContent)
        let result = await destination.performRequest(interactor: interactorType, request: request)
        await destination.handleAsyncInteractorResult(result: result, for: request)

    }

    public func asyncRequest<Destination>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, any Error> where Destination : InteractorResultHandling, InteractorType == Destination.InteractorType {

        let typedContent = typedRequestContent(from: content)
        let request = Request(action: actionType, content: typedContent)
        return await destination.performRequest(interactor: interactorType, request: request)

    }

    /// Overrides the default erasure-bridging behavior to apply `outputTransformer` (when present) to the Interactor's raw result. A `resultTransformer` supplied by the caller (e.g. an `Action`/sequence step's `ActionConfiguration`) takes precedence over this assistant's own `outputTransformer`.
    public func resolveAsyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: any InteractorRequestActionTypeable, content: ContentType?, resultTransformer: ContentTransformerWrapper<ContentType>?) async -> Result<ContentType, any Error> where Destination.InteractorType == InteractorType {

        let effectiveTransformer = resultTransformer ?? outputTransformer.map { ContentTransformerWrapper($0) }

        guard let actionType = actionType as? Request.ActionType else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(actionType)")
            return .failure(DestinationsError.incompatibleType(message: message))
        }

        let result = await asyncRequest(destination: destination, actionType: actionType, content: content)

        switch result {
            case .success(let rawResult):
                if let effectiveTransformer {
                    do {
                        return .success(try effectiveTransformer.transform(result: rawResult))
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

    private func typedRequestContent(from content: ContentType?) -> Request.RequestContentType? {
        guard let content else { return nil }

        if let inputTransformer, let transformed = try? inputTransformer.transform(input: content) {
            return transformed
        }

        return content as? Request.RequestContentType
    }

    #if swift(>=6.1)
    public func asyncRequest<Interactor: AsyncInteractable>(interactor: Interactor, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Interactor.Request == Request {

        let typedContent = typedRequestContent(from: content)
        let request = Request(action: actionType, content: typedContent)
        return await interactor.perform(request: request)

    }
    #else
    // Prior to Swift 6.1, `AsyncInteractable.ResultData` is a standalone associated type rather than being defined as `Request.ResultData`, so `Interactor.Request == Request` doesn't imply the two match.
    public func asyncRequest<Interactor: AsyncInteractable>(interactor: Interactor, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Interactor.Request == Request, Interactor.ResultData == Request.ResultData {

        let typedContent = typedRequestContent(from: content)
        let request = Request(action: actionType, content: typedContent)
        return await interactor.perform(request: request)

    }
    #endif

}
