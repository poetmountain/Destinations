//
//  ActionSequenceConfiguration.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

/// A configuration object that defines an ordered sequence of actions to be executed by an ``ActionSequence``.
///
/// Sequence steps are added using ``step(_:)`` and linked together with ``conduit(_:)``, which passes the result of one step into the next action. Each step except the last must have an output conduit assigned before another step can be appended.
///
/// ```swift
/// let config = try ActionSequenceConfiguration<MyInteractor, MyContent>()
///     .step(stepA)
///     .conduit(myConduit)
///     .step(stepB)
/// ```
///
/// - Note: `ActionSequenceConfiguration` is value-typed; each chained call returns a modified copy.
///
/// - Parameters:
///   - InteractorType: The interactor type used to perform each action, constrained to ``InteractorTypeable``.
///   - ContentType: The content type passed between steps, constrained to ``ContentTypeable``.
public struct ActionSequenceConfiguration<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: InteractorConfiguring, ActionCollectionConfiguring {
    
    /// A sequence has no single action type of its own; this placeholder satisfies the ``ActionConfiguring`` requirement. Each child carries its own real action type.
    public enum SequenceActionType: InteractorRequestActionTypeable {
        case sequence
    }
    public typealias ActionType = SequenceActionType

    public let interactorType: InteractorType? = nil

    public let actionType: SequenceActionType = .sequence
    
    /// Unused. A sequence has no single assistant. Each child builds its own.
    public let assistant: InteractorAssistantType = .basicAsync
    
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?

    /// An optional identifier of this sequence, carried onto the group's ``ActionResult``.
    public let identifier: (any ActionIdentifying)?
    
    public let shouldEndParentTaskOnFailure: Bool
    
    public let shouldSaveResult: Bool
    
    public let configurationType: ActionConfigurationType = .sequence
    
    public var merger: (any ActionResultsMerging<ContentType>)?

    /// Unused. A sequence has no children to save the results of.
    public let shouldSaveChildResults: Bool = true

    /// An array of action configurations which the group should run in sequence. The sequence is determined by the array order.
    public var actions: [any ActionConfiguring<InteractorType, ContentType>] = []

    public init(outputConduit: (any ActionSequenceConduiting<ContentType>)? = nil, identifier: (any ActionIdentifying)? = nil, shouldEndParentTaskOnFailure: Bool? = nil, shouldSaveResult: Bool? = nil) {
        self.outputConduit = outputConduit
        self.identifier = identifier
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure ?? false
        self.shouldSaveResult = shouldSaveResult ?? true
    }

    /// Adds a step representing an ``ActionPerformable`` object to the end of the sequence.
    /// - Parameter step: A configuration object for the action this step should perform.
    /// - Returns: A copy of this configuration with the step appended, allowing calls to be chained.
    /// - Throws: ``ActionError/missingConduit`` if the last action in the sequence has no output conduit.
    public func step(_ step: any ActionConfiguring<InteractorType, ContentType>) throws -> Self {
        var mutableSelf = self
        
        if let lastAction = mutableSelf.actions.last {
            guard lastAction.outputConduit != nil else {
                throw ActionError<ContentType>.missingConduit
            }
        }
        
        mutableSelf.actions.append(step)
        return mutableSelf
    }
    
    /// Associates an output conduit with the most recently added step.
    /// - Parameter conduit: The conduit that will carry output from the current step to the next.
    /// - Returns: A copy of this configuration with the conduit assigned to the last step, allowing calls to be chained.
    /// - Throws: ``ActionError/missingAction`` if no steps have been added yet.
    public func output(using transformer: (any ContentTransformable<ContentType>)? = nil) throws -> Self {
        var mutableSelf = self

        guard var lastAction = mutableSelf.actions.popLast() else {
            throw ActionError<ContentType>.missingAction
        }
        
        lastAction.outputConduit = ActionSequenceConduit<ContentType>(transformer: transformer)
        mutableSelf.actions.append(lastAction)
        
        return mutableSelf
    }
    
    public func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        // A group aggregates multiple child assistants and has no single assistant of its own, so it can't be nested as a child of another group.
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        let message = String(format: template, "\(actionType)")
        throw DestinationsError.unsupportedInteractorAssistantType(message: message)
    }

    public func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        var performables: [any ActionPerformable<ContentType>] = []
        for stepConfig in actions {
            let action = try stepConfig.buildAction(resultHandler: resultHandler)
            if let lastAction = performables.last {
                lastAction.outputConduit?.outputAction = action
            }
            performables.append(action)
        }
        return ActionSequence(actions: performables, identifier: identifier, outputConduit: outputConduit, shouldEndParentTaskOnFailure: shouldEndParentTaskOnFailure, shouldSaveResult: shouldSaveResult)
    }
}
