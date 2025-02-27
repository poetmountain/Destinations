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
    /// The basic assistant type, a ``DefaultInteractorAssistant`` assistant. This type is adequate for basic interactor requests which don't require a model state.
    case basic
    
    /// The basic assistant type for async interactors, a ``DefaultAsyncInteractorAssistant`` assistant. This type is adequate for basic interactor requests which don't require a model state.
    case basicAsync
    
    /// This type passes a custom assistant, used for configuring more advanced interactor requests that require supplying a model or other configuration needs.
    case custom(_ assistant: any InteractorAssisting)
}
