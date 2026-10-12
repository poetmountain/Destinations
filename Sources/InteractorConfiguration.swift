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

            case .transformer(let request, let result):
                if let result {
                    // ContentType is recovered from `result`'s erased Output type via existential opening,
                    // since this configuration has no ContentType of its own to work with.
                    assignTransformingAssistant(assignable: assignable, eventType: eventType, interactorType: interactorType, request: request, result: result)
                } else {
                    // No result transformer: ContentType defaults to Interactor.Request.ResultData, matching `.basicAsync`.
                    var typedRequest: (any ContentTransformable<Interactor.Request.ResultData, Interactor.Request.RequestContentType>)?
                    if let request {
                        typedRequest = request as? any ContentTransformable<Interactor.Request.ResultData, Interactor.Request.RequestContentType>
                        assert(typedRequest != nil, "\(Self.self): request transformer's Output must be \(Interactor.Request.RequestContentType.self) for event \(eventType)")
                    }

                    let assistant = DefaultAsyncInteractorAssistant<InteractorType, Interactor.Request, Interactor.Request.ResultData>(interactorType: interactorType, inputTransformer: typedRequest)
                    let assigned = assignable.tryAssignInteractorAssistant(assistant, for: eventType)
                    assert(assigned, "\(Self.self): destination's InteractorType/ContentType or EventType did not match this configuration's assistant for event \(eventType)")
                }
        }

    }

    /// Opens `result`'s erased `Output` type to recover the Destination's `ContentType`, builds a ``DefaultAsyncInteractorAssistant`` parameterized by it, and validates `request` (if supplied) against the now-concrete `ContentType`.
    private func assignTransformingAssistant<Output: ContentTransformable>(assignable: any AssistantAssigning, eventType: any Hashable, interactorType: InteractorType, request: (any ContentTransformable)?, result: Output) {

        guard let typedResult = result as? any ContentTransformable<Interactor.Request.ResultData, Output.Output> else {
            assertionFailure("\(Self.self): result transformer's Input must be \(Interactor.Request.ResultData.self) for event \(eventType)")
            return
        }

        var typedRequest: (any ContentTransformable<Output.Output, Interactor.Request.RequestContentType>)?
        if let request {
            typedRequest = request as? any ContentTransformable<Output.Output, Interactor.Request.RequestContentType>
            assert(typedRequest != nil, "\(Self.self): request transformer's Output must be \(Interactor.Request.RequestContentType.self) for event \(eventType)")
        }

        let assistant = DefaultAsyncInteractorAssistant<InteractorType, Interactor.Request, Output.Output>(interactorType: interactorType, inputTransformer: typedRequest, outputTransformer: typedResult)
        let assigned = assignable.tryAssignInteractorAssistant(assistant, for: eventType)
        assert(assigned, "\(Self.self): destination's InteractorType/ContentType or EventType did not match this configuration's assistant for event \(eventType)")
    }
}
