//
//  InteractorConfiguration.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This model is used to configure how an interactor is used in a Destination.
public struct InteractorConfiguration<InteractorType: InteractorTypeable, Interactor: AbstractInteractable>: InteractorConfiguring {
    public typealias ActionType = Interactor.Request.ActionType
    
    public let interactorType: InteractorType
    public let actionType: ActionType
    public let assistantType: InteractorAssistantType
        
    /// The initializer.
    /// - Parameters:
    ///   - interactorType: The type of interactor.
    ///   - actionType: The type of interactor request action.
    public init(interactorType: InteractorType, actionType: ActionType, assistantType: InteractorAssistantType) {
        self.interactorType = interactorType
        self.actionType = actionType
        self.assistantType = assistantType
    }
    
    public func assignInteractorAssistant<Destination: Destinationable>(destination: Destination, interactionType: Destination.UserInteractionType) where InteractorType == Destination.InteractorType {
        
        switch assistantType {
            case .basic:
                var assistant = DefaultInteractorAssistant<Destination.InteractorType, Interactor.Request, Destination.ContentType>(interactorType: interactorType, actionType: actionType)
                destination.assignInteractorAssistant(assistant: assistant, for: interactionType)
                
            case .basicAsync:
                var assistant = DefaultAsyncInteractorAssistant<Destination.InteractorType, Interactor.Request, Destination.ContentType>(interactorType: interactorType, actionType: actionType)
                destination.assignInteractorAssistant(assistant: assistant, for: interactionType)
                
            case .custom(let assistant):
                if var assistant = assistant as? any InteractorAssisting<Destination.InteractorType, Destination.ContentType> {
                    destination.assignInteractorAssistant(assistant: assistant, for: interactionType)
                }
        }
    
    }
}
