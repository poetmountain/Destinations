//
//  InteractorConfiguration.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This model is used to configure a specific action an Interactor should take.
public struct InteractorConfiguration<InteractorType: InteractorTypeable, Interactor: AbstractInteractable>: InteractorConfiguring {
    
    public typealias ActionType = Interactor.Request.ActionType

    public let interactorType: InteractorType?
    public let actionType: (any InteractorRequestActionTypeable)?
    public let assistantType: InteractorAssistantType?
        
    public let configurationType: ActionConfigurationType = .interactor
    
    /// The initializer.
    /// - Parameters:
    ///   - interactorType: The type of interactor.
    ///   - actionType: The type of interactor request action.
    public init(interactorType: InteractorType, actionType: ActionType, assistantType: InteractorAssistantType) {
        self.interactorType = interactorType
        self.actionType = actionType
        self.assistantType = assistantType
    }
    
    public func assignInteractorAssistant(to assignable: any AssistantAssigning, eventType: any Hashable) {
        guard let assistantType, let interactorType else { return }
        
        switch assistantType {
            case .basic:
                let assistant = DefaultInteractorAssistant<InteractorType, Interactor.Request, Interactor.Request.ResultData>(interactorType: interactorType)
                let assigned = assignable.tryAssignInteractorAssistant(assistant, for: eventType)
                assert(assigned, "\(Self.self): destination's InteractorType/ContentType or EventType did not match this configuration's assistant for event \(eventType)")

            case .basicAsync:
                let assistant = DefaultAsyncInteractorAssistant<InteractorType, Interactor.Request, Interactor.Request.ResultData>(interactorType: interactorType)
                let assigned = assignable.tryAssignInteractorAssistant(assistant, for: eventType)
                assert(assigned, "\(Self.self): destination's InteractorType/ContentType or EventType did not match this configuration's assistant for event \(eventType)")

            case .custom(let assistant):
                let assigned = assignable.tryAssignInteractorAssistant(assistant, for: eventType)
                assert(assigned, "\(Self.self): destination's InteractorType/ContentType or EventType did not match this configuration's custom assistant for event \(eventType)")
        }

    }
}
