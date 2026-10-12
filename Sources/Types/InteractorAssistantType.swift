//
//  InteractorAssistantType.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This enum represents the type of assistant to be used in configuring an ``InterfaceAssisting`` interactor object.
public enum InteractorAssistantType {
    /// The basic assistant type, a ``DefaultInteractorAssistant`` assistant. This type can be used for most Interactor requests where the Request's content type is the same as the Result's content type. If you need to pass in content with the request, this type can also handle that automatically if the content's type is the same as the Request's `RequestContentType`.
    case basic
    
    /// The basic assistant type for async interactors, a ``DefaultAsyncInteractorAssistant`` assistant. This type can be used for most async Interactor requests where the Request's content type is the same as the Result's content type. If you need to pass in content with the request, this type can also handle that automatically if the content's type is the same as the Request's `RequestContentType`.
    case basicAsync
    
    /// A basic async assistant type that bridges content types using the given transformers when the Interactor's `Request.RequestContentType`/`Request.ResultData` differ from the Destination's `ContentType`. If you don't need to do any custom logic in your assistant, in most cases you can just use this type if you only need to convert to and from the Interactor's Request and Result content types to the Destination's `ContentType`.
    ///
    /// - `request` converts a Destination's `ContentType` into the Request's `RequestContentType` before a request is made. Only needed when the two differ; pass `nil` to fall back to a direct cast, as ``basicAsync`` does.
    /// - `result` converts the Interactor's `Request.ResultData` into the Destination's `ContentType` after a request completes. Only needed when the two differ; pass `nil` to fall back to a direct cast, as ``basicAsync`` does.
    ///
    /// Passing `nil` for both is valid but behaves identically to ``basicAsync``.
    case transformer(request: (any ContentTransformable)?, result: (any ContentTransformable)?)
    
    /// This type passes a custom assistant, used for configuring more advanced interactor requests that require supplying a model or other configuration needs.
    case custom(_ assistant: any InteractorAssisting)
}
