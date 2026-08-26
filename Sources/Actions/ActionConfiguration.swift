//
//  ActionConfiguration.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An object which configures and builds an ``Action`` in an ``ActionSequence``. These configuration objects should be used in conjunction with an ``ActionSequenceConfiguration`` object, representing either a single sequence step, or a group of actions defined by an ``ActionSequenceGroupConfiguration`` object.
public struct ActionConfiguration<InteractorType: InteractorTypeable, ContentType: ContentTypeable, Interactor: AbstractInteractable>: ActionConfiguring where Interactor.Request.ResultData == ContentType {
    
    public typealias ActionType = Interactor.Request.ActionType

    public let interactorType: InteractorType?
    public let actionType: ActionType
    public let assistant: InteractorAssistantType
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    public let identifier: (any ActionIdentifying)?
    public let shouldEndParentTaskOnFailure: Bool
    public let shouldSaveResult: Bool

    public init(interactorType: InteractorType, action: ActionType, assistant: InteractorAssistantType, identifier: (any ActionIdentifying)?, shouldEndParentTaskOnFailure: Bool? = nil, shouldSaveResult: Bool? = nil) {
        self.interactorType = interactorType
        self.actionType = action
        self.assistant = assistant
        self.identifier = identifier
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure ?? false
        self.shouldSaveResult = shouldSaveResult ?? true
    }

    public func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {

        switch assistant {
            case .basic:
                // basic assistants are non-async, and as such aren't supported in ActionSequences
                let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
                let message = String(format: template, "\(actionType)")
                throw DestinationsError.unsupportedInteractorAssistantType(message: message)

            case .basicAsync:
                guard let interactorType else {
                    let template = DestinationsSupport.errorMessage(for: .missingInteractorType(message: ""))
                    let message = String(format: template)
                    throw DestinationsError.missingInteractorType(message: message)
                }
                return DefaultAsyncInteractorAssistant<InteractorType, Interactor.Request, ContentType>(interactorType: interactorType)

            case .custom(let customAssistant):
                guard let customAssistant = customAssistant as? any AsyncInteractorAssisting<InteractorType, ContentType> else {
                    let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                    let message = String(format: template, "\(actionType)")
                    throw DestinationsError.missingInterfaceActionAssistant(message: message)
                }
                return customAssistant
        }
    }

    /// Builds a runnable sequence step from this configuration, constructing the interactor assistant the step will use to make its request. Building the assistant here allows access to the concrete Interactor type, which is erased at the sequence level.
    /// - Parameter resultHandler: The object which should handle the results of the step's interactor request.
    /// - Returns: A `Result` containing the step, or a failure if the configured assistant is incompatible with this configuration's types.
    public func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        let interactorAssistant = try buildAssistant()
        return Action(actionType: actionType, identifier: identifier, assistant: interactorAssistant, resultHandler: resultHandler, outputConduit: outputConduit, shouldEndParentTaskOnFailure: shouldEndParentTaskOnFailure, shouldSaveResult: shouldSaveResult)
    }
}
