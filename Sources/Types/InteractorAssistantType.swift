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
    
    /// This type passes a custom assistant, used for configuring more advanced interactor requests that require supplying a model or other configuration needs.
    case custom(_ assistant: any InteractorAssisting)
}
